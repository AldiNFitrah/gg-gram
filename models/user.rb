require './db/mysql_connector.rb'


class User
  attr_reader :id, :username
  attr_accessor :email, :bio_description

  @@db_client = MySqlClient.instance()

  def initialize(params)
    @id = params[:id]
    @username = params[:username]
    @email = params[:email]&.downcase()
    @bio_description = params[:bio_description]
  end

  def save()
    self.validate()

    @@db_client.query("
      INSERT INTO users(username, email, bio_description) VALUES
        ('#{@username}', '#{@email}', '#{@bio_description}')
    ")
    @id = @@db_client.last_id

    return self
  end

  def validate()
    self.validate_id()

    self.validate_username()
    self.validate_email()
    self.validate_bio_description()
  end

  def validate_id()
    if !@id.nil?
      raise StandardError.new('this user has been saved before')
    end
  end

  def validate_username()
    if @username.nil?
      raise StandardError.new('username is required for user')
    end

    count_users = @@db_client.query("
      SELECT COUNT(*) AS count
      FROM users
      WHERE username = '#{@username}'
    ")

    num_of_users_with_same_username = count_users.first['count']
    if num_of_users_with_same_username > 0
      raise StandardError.new("user with username '#{@username}' already exists")
    end
  end

  def validate_email()
    if @email.nil?
      raise StandardError.new('email is required for user')
    end

    count_users = @@db_client.query("
      SELECT COUNT(*) AS count
      FROM users
      WHERE email = '#{@email}'
    ")

    num_of_users_with_same_email = count_users.first['count']
    if num_of_users_with_same_email > 0
      raise StandardError.new("user with email '#{@email}' already exists")
    end
  end

  def validate_bio_description()
    if @bio_description && @bio_description.length > 1000
      raise StandardError.new('bio description must not exceed 1000 characters')
    end
  end


  def self.all()
    raw_data = @@db_client.query("
      SELECT *
      FROM users
    ")
    return convert_sql_to_ruby(raw_data)
  end

  def self.get_by_id(id)
    raw_data = @@db_client.query("
      SELECT *
      FROM users
      WHERE id = #{id}
    ")

    if raw_data.size() == 0
      raise StandardError.new('user is not found')
    end

    return convert_sql_to_ruby(raw_data)[0]
  end

  def self.convert_sql_to_ruby(raw_data)
    users = []
    raw_data.each do |data|
      user = User.new({
        id: data['id'],
        username: data['username'],
        email: data['email'],
        bio_description: data['bio_description'],
      })
      users.push(user)
    end

    return users
  end

  def ==(other)
    return (
      self.id == other.id &&
      self.username == other.username &&
      self.email == other.email &&
      self.bio_description == other.bio_description
    )
  end
end
