require 'rack/test'
require 'cgi'

require './controllers/user_controller.rb'
require './main.rb'
require './models/post.rb'
require './models/user.rb'


describe PostController do

  include Rack::Test::Methods

  def app
    return GgGramApp.new
  end

  before(:each) do
    @user = User.new({
      username: 'username',
      email: 'abc@abc.com',
      bio_description: 'this is bio',
    })
    @user.save()
  end

  describe '.create' do
    context 'post only content data to a valid user via url' do
      before(:each) do
        post("/api/users/#{@user.id}/post", params={
          'content'=> 'this is a content',
        })
      end

      it 'is created' do
        expect(Post.all().count()).to(eq(1))
      end

      it 'response the created post' do
        response_body = eval(last_response.body)

        expect(last_response.status).to(eq(201))

        expect(response_body[:id]).to(be_kind_of(Integer))
        expect(response_body[:created_at]).not_to(be_nil())
        expect(response_body[:updated_at]).not_to(be_nil())
        expect(response_body).to(include({
          :user_id => @user.id,
          :content => 'this is a content',
          :attachment_url => '',
          :hashtags => [],
        }))
      end
    end

    context 'post valid data with content containing some hashtags' do
      before(:each) do
        post("/api/users/#{@user.id}/post", params={
          'content'=> 'delete soon #stopInsecure and #beYourself',
        })
        @response_body = eval(last_response.body)
      end

      it 'is created and store the hashtags' do
        post_id = @response_body[:id]
        post = Post.get_by_id(post_id)

        expect(Post.all().count()).to(eq(1))
        expect(post.hashtags.length()).to(eq(2))
        expect(post.hashtags).to(match_array(["#stopInsecure", "#beYourself"]))
      end

      it 'response the hashtags' do
        expect(last_response.status).to(eq(201))

        expect(@response_body[:hashtags].length()).to(eq(2))
        expect(@response_body[:hashtags]).to(match_array(["#stopInsecure", "#beYourself"]))
        response_body = eval(last_response.body)
      end
    end

    context 'post valid data to an unknown user' do
      before(:each) do
        post("/api/users/3243/post", params={
          'content'=> 'content',
        })
        @response_body = eval(last_response.body)
      end

      it 'response with bad request status code' do
        expect(last_response.status).to(eq(400))
        expect(@response_body[:error]).to(include("user"))
      end
    end
  end

  describe '.list' do
    context 'get with a hashtag that is contained in 2 posts' do
      before(:each) do
        Post.new({
          user_id: @user.id,
          content: '#COMPFEST13 and #TechToElevate',
          attachment_url: '/public/abc.jpg',
          hashtags: ['#COMPFEST13', '#TechToElevate'],
        }).save()

        Post.new({
          user_id: @user.id,
          content: '#GenerasiGigih and #TechToElevate',
          attachment_url: '/public/abc.jpg',
          hashtags: ['#GenerasiGigih', '#TechToElevate'],
        }).save()

        escaped_hashtag = CGI.escape('#TechToElevate')
        url = "/api/posts?hashtag=#{escaped_hashtag}"
        get(url)
        @response_body = eval(last_response.body)
      end

      it 'returns the 2 posts' do
        expect(last_response.status).to(eq(200))
        expect(@response_body.length).to(eq(2))
      end
    end

    context 'get without a hashtag' do
      it 'response with 400 bad request' do
        get("/api/posts")
        
        expect(last_response.status).to(eq(400))
      end
    end

    context 'get with a hashtag that is contained in no posts' do
      before(:each) do
        escaped_hashtag = CGI.escape('#LampauiBatasmu')
        url = "/api/posts?hashtag=#{escaped_hashtag}"
        get(url)
        @response_body = eval(last_response.body)
      end

      it 'returns 0 posts' do
        expect(last_response.status).to(eq(200))
        expect(@response_body.length).to(eq(0))
      end
    end
  end
end
