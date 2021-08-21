require 'json'
require 'securerandom'

require './models/comment.rb'


class CommentController
  def self.create(params)
    hashtags = extract_hashtags(params['content'])

    is_with_file = !params['attachment'].nil?
    file_path = nil
    if is_with_file
      file_info = params['attachment']
      filename = file_info['filename']
      file_ext = File.extname(filename)
      generated_random_filename = SecureRandom.urlsafe_base64() + file_ext
      file_content = file_info['tempfile']
      file_path = "public/#{generated_random_filename}"
    end

    comment = Comment.new({
      user_id: params['user_id'],
      post_id: params['post_id'],
      content: params['content'],
      attachment_path: file_path,
      hashtags: hashtags,
    })

    begin
      if is_with_file
        File.open(file_path, 'wb') do |file|
          file.write(file_content.read())
        end
      end
      comment.save()
    rescue Exception => e
      if is_with_file
        File.delete(file_path)
      end
      return [400, {error: e.to_s}.to_json()]
    end

    return [201, comment.to_json()]
  end

  def self.extract_hashtags(content)
    hashtags = []

    words = content.split()
    words.each do |word|
      downcased_word = word.downcase()
      if valid_hashtag?(downcased_word)
        hashtags.push(downcased_word)
      end
    end

    return hashtags.uniq
  end

  def self.valid_hashtag?(word)
    return (
      word.is_a?(String) &&
      word.start_with?('#') &&
      word.length > 1
    )
  end

end
