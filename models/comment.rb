require './db/mysql_connector.rb'
require './models/post.rb'
require './models/user.rb'


class Comment
  attr_reader :id, :user_id, :post_id, :created_at, :updated_at
  attr_accessor :content, :attachment_path, :hashtags

  @@db_client = MySqlClient.instance()

  def initialize(params)
    @id = params[:id]
    @user_id = params[:user_id]
    @post_id = params[:post_id]
    @content = params[:content]
    @attachment_path = params[:attachment_path]
    @hashtags = params[:hashtags] || Array.new()
    @created_at = params[:created_at]
    @updated_at = params[:updated_at]
  end

  def save()
    self.validate()


    @@db_client.query("
      INSERT INTO comments(user_id, post_id, content, attachment_path, hashtags_str) VALUES
        (#{@user_id}, #{@post_id}, '#{@content}', '#{@attachment_path}', '#{@hashtags}')
    ")
    @id = @@db_client.last_id

    self.refresh_from_db()

    return self
  end

  def validate()
    self.validate_id()

    self.validate_user_id()
    self.validate_post_id()
    self.validate_content()
    self.validate_hashtags()
  end

  def validate_id()
    if !@id.nil?
      raise StandardError.new('this comment has been saved before')
    end
  end

  def validate_user_id()
    begin
      user = User.get_by_id(@user_id)
    rescue Exception
      raise StandardError.new("there is no user with id #{@user_id}")
    end
  end

  def validate_post_id()
    begin
      post = Post.get_by_id(@post_id)
    rescue Exception
      raise StandardError.new("there is no post with id #{@post_id}")
    end
  end

  def validate_content()
    if @content && @content.length > 1000
      raise StandardError.new('comment content must not exceed 1000 characters')
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
    new_data = Comment.get_by_id(@id)

    @user_id = new_data.user_id
    @post_id = new_data.post_id
    @content = new_data.content
    @attachment_path = new_data.attachment_path
    @hashtags = new_data.hashtags
    @created_at = new_data.created_at
    @updated_at = new_data.updated_at
  end

  def self.all()
    raw_data = @@db_client.query("
      SELECT *
      FROM comments
    ")
    return convert_sql_to_ruby(raw_data)
  end

  def self.get_by_id(id)
    raw_data = @@db_client.query("
      SELECT *
      FROM comments
      WHERE id = #{id}
    ")

    if raw_data.size() == 0
      raise StandardError.new('comment is not found')
    end

    return convert_sql_to_ruby(raw_data)[0]
  end

  def self.get_last_posted(year: 0, month: 0, week: 0, day: 0, hour: 0, minute: 0, second: 0)
    raw_data = @@db_client.query("
      SELECT *
      FROM comments
      WHERE
        updated_at >= (
          NOW()
          - INTERVAL #{year} YEAR
          - INTERVAL #{month} MONTH
          - INTERVAL #{week} WEEK
          - INTERVAL #{day} DAY
          - INTERVAL #{hour} HOUR
          - INTERVAL #{minute} MINUTE
          - INTERVAL #{second} SECOND
        )
    ")
    return convert_sql_to_ruby(raw_data)
  end

  def self.convert_sql_to_ruby(raw_data)
    comments = []
    raw_data.each do |data|
      comment = Comment.new({
        id: data['id'],
        user_id: data['user_id'],
        post_id: data['post_id'],
        content: data['content'],
        attachment_path: data['attachment_path'],
        hashtags: eval(data['hashtags_str']),
        created_at: data['created_at'],
        updated_at: data['updated_at'],
      })
      comments.push(comment)
    end

    return comments
  end

  def ==(other)
    return (
      self.id == other.id &&
      self.user_id == other.user_id &&
      self.post_id == other.post_id &&
      self.content == other.content &&
      self.attachment_path == other.attachment_path &&
      self.hashtags == other.hashtags &&
      self.created_at == other.created_at &&
      self.updated_at == other.updated_at
    )
  end

  def to_hash()
    return {
      'id' => @id,
      'user_id' => @user_id,
      'post_id' => @post_id,
      'content' => @content,
      'attachment_path' => @attachment_path,
      'hashtags' => @hashtags,
      'created_at' => @created_at,
      'updated_at' => @updated_at,
    }
  end

  def to_json()
    return self.to_hash().to_json()
  end
end
