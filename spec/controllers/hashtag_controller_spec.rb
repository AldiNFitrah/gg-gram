require 'rack/test'

require './db/mysql_connector.rb'
require './models/comment.rb'
require './models/post.rb'
require './models/user.rb'


describe HashtagController do

  include Rack::Test::Methods

  def app
    return GgGramApp.new
  end

  db_client = MySqlClient.instance()

  describe '.get_trending' do
    before(:each) do
      @user = User.new({
        username: 'username',
        email: 'abc@abc.com',
        bio_description: 'this is bio',
      })
      @user.save()
    end

    context 'given a post and a comment each contains different hashtag' do
      before(:each) do
        post = Post.new({
          user_id: @user.id,
          content: 'content',
          attachment_path: '/public/abc.jpg',
          hashtags: ['#lampaui'],
        }).save()

        Comment.new({
          user_id: @user.id,
          post_id: post.id,
          content: 'comment',
          attachment_path: '/public/abc.jpg',
          hashtags: ['#batasmu'],
        }).save()

        get('/api/hashtags/trending')
        @response_body = eval(last_response.body)
      end

      it 'counts both hashtag as trending' do
        expect(last_response.status).to(eq(200))
        expect(@response_body).to(include({
          :'#batasmu' => 1,
          :'#lampaui' => 1,
        }))
      end
    end

    context 'given no post and comment in last 24 hours' do
      before(:each) do
        db_client.query("
          INSERT INTO posts(user_id, content, attachment_path, hashtags_str, created_at, updated_at) VALUES
            (#{@user.id}, 'abc', '', '#{["#goto"]}', NOW() - INTERVAL 25 HOUR, NOW() - INTERVAL 25 HOUR)
        ")
        post_id = db_client.last_id
        post = Post.get_by_id(post_id)

        db_client.query("
          INSERT INTO comments(user_id, post_id, content, attachment_path, hashtags_str, created_at, updated_at) VALUES
            (#{@user.id}, #{post_id}, 'abc', '', '#{["#together"]}', NOW() - INTERVAL 25 HOUR, NOW() - INTERVAL 25 HOUR)
        ")

        get('/api/hashtags/trending')
        @response_body = eval(last_response.body)
      end

      it 'returns no trending hashtag' do
        expect(last_response.status).to(eq(200))
        expect(@response_body.size()).to(eq(0))
      end
    end
  end
end