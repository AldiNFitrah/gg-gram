require 'cgi'
require 'rack/test'

require './main.rb'
require './models/comment.rb'
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

    @post = Post.new({
      user_id: @user.id,
      content: 'this is a content',
      attachment_url: '/public/abc.jpg',
      hashtags: ['#Lampaui', '#Batasmu'],
    })
    @post.save()
  end

  describe '.create' do
    context 'post only content data to a valid user and post via url' do
      before(:each) do
        post("/api/posts/#{@post.id}/comment", params={
          'user_id' => @user.id,
          'content' => 'to be or not to be',
        })
      end

      it 'is created' do
        expect(Comment.all().count()).to(eq(1))
      end

      it 'response the created post' do
        response_body = eval(last_response.body)

        expect(last_response.status).to(eq(201))

        expect(response_body[:id]).to(be_kind_of(Integer))
        expect(response_body[:created_at]).not_to(be_nil())
        expect(response_body[:updated_at]).not_to(be_nil())
        expect(response_body).to(include({
          :user_id => @user.id,
          :post_id => @post.id,
          :content => 'to be or not to be',
        }))
      end
    end

    context 'post valid data with content containing some hashtags' do
      before(:each) do
        post("/api/posts/#{@post.id}/comment", params={
          'user_id' => @user.id,
          'content'=> 'delete soon #stopInsecure and #beYourself',
        })
        @response_body = eval(last_response.body)
      end

      it 'is created and store the hashtags' do
        comment_id = @response_body[:id]
        comment = Comment.get_by_id(comment_id)

        expect(Comment.all().count()).to(eq(1))
        expect(comment.hashtags.length()).to(eq(2))
        expect(comment.hashtags).to(match_array(["#stopInsecure", "#beYourself"]))
      end

      it 'response the hashtags' do
        expect(last_response.status).to(eq(201))

        expect(@response_body[:hashtags].length()).to(eq(2))
        expect(@response_body[:hashtags]).to(match_array(["#stopInsecure", "#beYourself"]))
      end
    end

    context 'post valid data to an unknown user' do
      before(:each) do
        post("/api/posts/#{@post.id}/comment", params={
          'user_id' => 532453,
          'content'=> 'content',
        })
        @response_body = eval(last_response.body)
      end

      it 'response with bad request status code' do
        expect(last_response.status).to(eq(400))
        expect(@response_body[:error]).to(include("user"))
      end
    end

    context 'post valid data to an unknown post' do
      before(:each) do
        post("/api/posts/523423/comment", params={
          'user_id' => @user.id,
          'content'=> 'content',
        })
        @response_body = eval(last_response.body)
      end

      it 'response with bad request status code' do
        expect(last_response.status).to(eq(400))
        expect(@response_body[:error]).to(include("post"))
      end
    end
  end

end
