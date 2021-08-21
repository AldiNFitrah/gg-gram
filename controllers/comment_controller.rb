require 'json'

require './models/comment.rb'


class CommentController
  def self.create(params)
    hashtags = extract_hashtags(params['content'])

    comment = Comment.new({
      user_id: params['user_id'],
      post_id: params['post_id'],
      content: params['content'],
      attachment_url: params['attachment_url'],
      hashtags: hashtags,
    })

    begin
      comment.save()
    rescue Exception => e
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

    return hashtags
  end

  def self.valid_hashtag?(word)
    return (
      word.is_a?(String) &&
      word.start_with?('#') &&
      word.length > 1
    )
  end

end
