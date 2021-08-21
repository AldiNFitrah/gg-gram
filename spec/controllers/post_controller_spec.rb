require 'cgi'
require 'fileutils'
require 'rack/test'

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
          :attachment_path => '',
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
        expect(post.hashtags).to(match_array(["#stopinsecure", "#beyourself"]))
      end

      it 'response the hashtags' do
        expect(last_response.status).to(eq(201))

        expect(@response_body[:hashtags].length()).to(eq(2))
        expect(@response_body[:hashtags]).to(match_array(["#stopinsecure", "#beyourself"]))
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

    context 'post valid data with content containing duplicated hashtags with mixed cases' do
      before(:each) do
        post("/api/users/#{@user.id}/post", params={
          'content'=> 'delete soon #stopInsecure and #beYourself #StopInsecure #BeYourself',
        })
        @response_body = eval(last_response.body)
      end

      it 'is created' do
        expect(last_response.status).to(eq(201))
      end

      it 'stores the downcased hashtag and remove duplicates' do
        post_id = @response_body[:id]

        post = Post.get_by_id(post_id)

        expect(post.hashtags.length).to(eq(2))
        expect(post.hashtags).to(match_array(['#beyourself', '#stopinsecure']))
      end
    end
  end

  describe '.create with attachment' do
    context 'post content data with attachment to a valid user via url' do
      before(:each) do
        FileUtils.mkdir_p('test')
        File.open('test/file.txt', 'wb') do |f|
          f.write('abc')
        end
        @file = File.open('test/file.txt', 'wb')
        @uploaded_file = Rack::Test::UploadedFile.new(@file)

        allow(File).to(receive(:open).and_return(@file))
        allow(File).to(receive(:delete))
      end
      
      it 'is created' do
        post("/api/users/#{@user.id}/post", params={
          'content' => 'content with attachment',
          'attachment' => @uploaded_file,
        })
        expect(Post.all().count()).to(eq(1))
      end
      
      it 'create file and not delete it' do
        expect(File).to(receive(:open))
        expect(File).not_to(receive(:delete))

        post("/api/users/#{@user.id}/post", params={
          'content' => 'content with attachment',
          'attachment' => @uploaded_file,
        })
      end

      it 'response the created post' do
        post("/api/users/#{@user.id}/post", params={
          'content' => 'content with attachment',
          'attachment' => @uploaded_file,
        })
        response_body = eval(last_response.body)

        expect(last_response.status).to(eq(201))

        expect(response_body[:id]).to(be_kind_of(Integer))
        expect(response_body[:created_at]).not_to(be_nil())
        expect(response_body[:updated_at]).not_to(be_nil())
        expect(response_body).to(include({
          :user_id => @user.id,
          :content => 'content with attachment',
          :hashtags => [],
        }))
      end

      after(:each) do
        @file.close()
        FileUtils.remove_dir('test')
      end
    end

    context 'post invalid data with attachment via url' do
      before(:each) do
        FileUtils.mkdir_p('test')
        File.open('test/file.txt', 'wb') do |f|
          f.write('abc')
        end
        @file = File.open('test/file.txt', 'wb')
        @uploaded_file = Rack::Test::UploadedFile.new(@file)

        allow(File).to(receive(:open).and_return(@file))
      end

      it 'not created' do
        post("/api/users/#{@user.id}/post", params={
          'content' => 'c' * 1001,
          'attachment' => @uploaded_file,
        })

        expect(Post.all().count()).to(eq(0))
      end

      it 'create a file then delete it again' do
        expect(File).to(receive(:open))
        expect(File).to(receive(:delete))

        post("/api/users/#{@user.id}/post", params={
          'content' => 'c' * 1001,
          'attachment' => @uploaded_file,
        })
      end

      after(:each) do
        @file.close()
        FileUtils.remove_dir('test')
      end
    end
  end

  describe '.list' do
    context 'get with a hashtag that is contained in 2 posts' do
      before(:each) do
        Post.new({
          user_id: @user.id,
          content: '#COMPFEST13 and #TechToElevate',
          attachment_path: '/public/abc.jpg',
          hashtags: ['#COMPFEST13', '#TechToElevate'],
        }).save()

        Post.new({
          user_id: @user.id,
          content: '#GenerasiGigih and #TechToElevate',
          attachment_path: '/public/abc.jpg',
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
