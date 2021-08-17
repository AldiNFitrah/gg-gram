require './db/mysql_connector.rb'


class Post
  attr_reader :id, :user_id, :created_at, :updated_at
  attr_accessor :content, :attachment_url, :hashtags_str

  @@db_client = MySqlClient.instance()

  def initialize(params)
    @id = params[:id]
    @user_id = params[:user_id]
    @content = params[:content]
    @attachment_url = params[:attachment_url]
    @hashtags_str = params[:hashtags_str]&.downcase()
    @created_at = params[:created_at]
    @updated_at = params[:updated_at]
  end

  def save()
    self.validate()

    esacaped_hashtags_str = @@db_client.escape(@hashtags_str)

    @@db_client.query("
      INSERT INTO posts(user_id, content, attachment_url, hashtags_str) VALUES
        (#{@user_id}, '#{@content}', '#{@attachment_url}', '#{esacaped_hashtags_str}')
    ")
    @id = @@db_client.last_id

    return self
  end

  def validate()
    self.validate_id()

    self.validate_user_id()
    self.validate_content()
    self.validate_hashtags_str()
  end

  def validate_id()
    if !@id.nil?
      raise StandardError.new('this post has been saved before')
    end
  end

  def validate_user_id()
    count_users = @@db_client.query("
      SELECT COUNT(*) AS count
      FROM users
      WHERE id = #{@user_id}
    ")

    num_of_users_with_same_id = count_users.first['count']
    if num_of_users_with_same_id == 0
      raise StandardError.new("there is no user with id #{@user_id}")
    end
  end

  def validate_content()
    if @content && @content.length > 1000
      raise StandardError.new('post content must not exceed 1000 characters')
    end
  end

  def validate_hashtags_str()
    begin
      hashtag_array = eval(@hashtags_str)
    rescue SyntaxError
      raise StandardError.new('hashtags_str must be a valid array')
    end

    if !hashtag_array.is_a?(Array)
      raise StandardError.new('hashtags_str must be a valid array')
    end

    hashtag_array = eval(@hashtags_str)
    hashtag_array.each do |hashtag|
      if !hashtag.is_a?(String)
        raise StandardError.new('hashtags_str contains a not-a-string element')
      end
      if !hashtag.start_with?('#')
        raise StandardError.new('hashtags_str contains an invalid hashtag')
      end
    end
  end

  def self.all()
    raw_data = @@db_client.query("
      SELECT *
      FROM posts
    ")
    return convert_sql_to_ruby(raw_data)
  end

  def self.get_by_id(id)
    raw_data = @@db_client.query("
      SELECT *
      FROM posts
      WHERE id = #{id}
    ")

    if raw_data.size() == 0
      raise StandardError.new('post is not found')
    end

    return convert_sql_to_ruby(raw_data)[0]
  end

  def self.convert_sql_to_ruby(raw_data)
    posts = []
    raw_data.each do |data|
      post = Post.new({
        id: data['id'],
        user_id: data['user_id'],
        content: data['content'],
        attachment_url: data['attachment_url'],
        hashtags_str: data['hashtags_str'],
        created_at: data['created_at'],
        updated_at: data['updated_at'],
      })
      posts.push(post)
    end

    return posts
  end

  def ==(other)
    return (
      self.id == other.id &&
      self.user_id == other.user_id &&
      self.content == other.content &&
      self.attachment_url == other.attachment_url &&
      self.hashtags_str == other.hashtags_str &&
      self.created_at == other.created_at &&
      self.updated_at == other.updated_at
    )
  end
end
