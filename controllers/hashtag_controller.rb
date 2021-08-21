require 'json'

require './models/comment.rb'
require './models/post.rb'

class HashtagController
  def self.get_trending(limit)
    posts = Post.get_last_posted(hour: 24)
    comments = Comment.get_last_posted(hour: 24)

    posts_hashtags = posts.map { |post| post.hashtags }
    comments_hashtags = comments.map { |comment| comment.hashtags }

    hashtags_count = get_hashtags_count(posts_hashtags + comments_hashtags)
    sorted_hashtags_count_array = hashtags_count.sort_by { |_key, value| value }.reverse()
    top_hashtags_count_array = sorted_hashtags_count_array.slice(0, limit)

    return [200, top_hashtags_count_array.to_h.to_json]
  end

  def self.get_hashtags_count(hashtags_list)
    hashtags = hashtags_list.flatten()

    hashtags_count = {}
    while !hashtags.empty?
      hashtag = hashtags[0]
      hashtag_count = hashtags.count(hashtag)
      hashtags.delete(hashtag)

      hashtags_count[hashtag] = hashtag_count
    end

    return hashtags_count
  end
end
