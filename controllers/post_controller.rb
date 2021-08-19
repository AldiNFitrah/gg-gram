require './models/post.rb'


class PostController
  def self.create(params)
    hashtags = extract_hashtags(params['content'])

    post = Post.new({
      user_id: params['user_id'],
      content: params['content'],
      attachment_url: params['attachment_url'],
      hashtags: hashtags,
    })

    begin
      post.save()
    rescue Exception => e
      return [400, {error: e.to_s}.to_json()]
    end

    return [201, post.to_json()]
  end

  def self.extract_hashtags(content)
    hashtags = []

    words = content.split()
    words.each do |word|
      if valid_hashtag?(word)
        hashtags.push(word)
      end
    end

    return hashtags
  end

  def self.valid_hashtag?(word)
    return (
      word.start_with?('#') &&
      word.length > 1
    )
  end
end
