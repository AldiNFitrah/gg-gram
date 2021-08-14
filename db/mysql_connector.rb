require 'mysql2'
require 'dotenv'

Dotenv.load


class MySqlClient

  def self.instance()
    if @instance.nil?
      @instance = get_client()
    end

    return @instance
  end

  def self.get_client()
    @instance = Mysql2::Client.new(
      host: ENV['DB_HOST'],
      username: ENV['DB_USERNAME'],
      password: ENV['DB_PASSWORD'],
      database: ENV['DB_NAME'],
    )
  end

  def self.truncate_all()
    queries = instance().query("
      SELECT
        Concat('TRUNCATE TABLE ',table_schema,'.',TABLE_NAME, ';') AS 'truncate_table'
      FROM
        INFORMATION_SCHEMA.TABLES
      WHERE
        table_schema IN ('#{ENV['DB_NAME']}')
    ")

    instance().query("SET FOREIGN_KEY_CHECKS = 0")

    queries.each do |query|
      instance.query(query['truncate_table'])
    end

    instance().query("SET FOREIGN_KEY_CHECKS = 1")
  end

  private_class_method :get_client, :new
end
