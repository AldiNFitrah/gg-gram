require 'json'

require './models/post.rb'


class PostController
  def self.create(params)
    hashtags = extract_hashtags(params['content'])

    post = Post.new({
      user_id: params['user_id'],
      content: params['content'],
      attachment_path: params['attachment_path'],
      hashtags: hashtags,
    })

    begin
      post.save()
    rescue Exception => e
      return [400, {error: e.to_s}.to_json()]
    end

    return [201, post.to_json()]
  end

  def self.list(params)
    if !valid_hashtag?(params['hashtag'])
      return [400, {error: 'need to filter by one valid hashtag'}.to_json()]
    end

    hashtag = params['hashtag']
    posts = Post.all()
    filtered_posts = filter_posts_by_hashtag(posts, hashtag)
    serialized_posts = serialize_posts(filtered_posts)
    return [200, serialized_posts]
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

  def self.filter_posts_by_hashtag(posts, hashtag)
    filtered_posts = []
    posts.each do |post|
      if post_contains_hashtag?(post, hashtag)
        filtered_posts.push(post)
      end
    end

    return filtered_posts
  end

  def self.post_contains_hashtag?(post, hashtag)
    return post.hashtags.include?(hashtag)
  end

  def self.serialize_posts(posts)
    serialized_posts = []
    posts.each do |post|
      serialized_posts.push(post.to_hash)
    end

    return serialized_posts.to_json()
  end
end
