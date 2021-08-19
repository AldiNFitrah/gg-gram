require './db/mysql_connector.rb'
require './models/user.rb'


class Post
  attr_reader :id, :user_id, :created_at, :updated_at
  attr_accessor :content, :attachment_url, :hashtags

  @@db_client = MySqlClient.instance()

  def initialize(params)
    @id = params[:id]
    @user_id = params[:user_id]
    @content = params[:content]
    @attachment_url = params[:attachment_url]
    @hashtags = params[:hashtags] || Array.new()
    @created_at = params[:created_at]
    @updated_at = params[:updated_at]
  end

  def save()
    self.validate()

    @@db_client.query("
      INSERT INTO posts(user_id, content, attachment_url, hashtags_str) VALUES
        (#{@user_id}, '#{@content}', '#{@attachment_url}', '#{@hashtags}')
    ")
    @id = @@db_client.last_id

    self.refresh_from_db()

    return self
  end

  def validate()
    self.validate_id()

    self.validate_user_id()
    self.validate_content()
    self.validate_hashtags()
  end

  def validate_id()
    if !@id.nil?
      raise StandardError.new('this post has been saved before')
    end
  end

  def validate_user_id()
    begin
      user = User.get_by_id(@user_id)
    rescue Exception
      raise StandardError.new("there is no user with id #{@user_id}")
    end
  end

  def validate_content()
    if @content && @content.length > 1000
      raise StandardError.new('post content must not exceed 1000 characters')
    end
  end

  def validate_hashtags()
    if !@hashtags.is_a?(Array)
      raise StandardError.new('hashtags must be a valid array')
    end

    @hashtags.each do |hashtag|
      if !hashtag.is_a?(String)
        raise StandardError.new('hashtags contains a not-a-string element')
      end
      if !hashtag.start_with?('#')
        raise StandardError.new('hashtags contains an invalid hashtag')
      end
    end
  end

  def refresh_from_db()
    new_data = Post.get_by_id(@id)

    @user_id = new_data.user_id
    @content = new_data.content
    @attachment_url = new_data.attachment_url
    @hashtags = new_data.hashtags
    @created_at = new_data.created_at
    @updated_at = new_data.updated_at
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
        hashtags: eval(data['hashtags_str']),
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
      self.hashtags == other.hashtags &&
      self.created_at == other.created_at &&
      self.updated_at == other.updated_at
    )
  end

end
