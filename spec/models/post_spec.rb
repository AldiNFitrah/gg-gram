require './db/mysql_connector.rb'
require './models/post.rb'
require './models/user.rb'


describe Post do

  db_client = MySqlClient.instance()

  before(:each) do
    @user = User.new({
      username: 'username',
      email: 'abc@abc.com',
      bio_description: 'this is bio',
    })

    @user.save()
  end

  describe '#save' do
    context 'given valid data' do
      it 'saved' do
        post = Post.new({
          user_id: @user.id,
          content: 'this is a content',
          attachment_url: '/public/abc.jpg',
          hashtags_str: "['#COMPFEST13', '#TechToElevate']",
        })
        post.save()

        raw_data = db_client.query("
          SELECT COUNT(*) AS count
          FROM posts
        ")
        num_of_posts = raw_data.first['count']

        expect(num_of_posts).to(eq(1))
      end
    end
    
    context 'given valid data and try to save twice' do
      it 'raises error and only saved once' do
        post = Post.new({
          user_id: @user.id,
          content: 'this is a content',
          attachment_url: '/public/abc.jpg',
          hashtags_str: "['#COMPFEST13', '#TechToElevate']",
        })
        post.save()

        post.content = 'new content'
        expect{ post.save() }.to(raise_error(StandardError, /saved/))
      end
    end

    context 'given unknown user_id' do
      it 'raises error and not saved' do
        post = Post.new({
          user_id: 54125,
          content: 'this is a content',
          attachment_url: '/public/abc.jpg',
          hashtags_str: "['#COMPFEST13', '#TechToElevate']",
        })

        expect{ post.save() }.to(raise_error(StandardError, /user/))
      end
    end

    context 'given content is longer than 1000 characters' do
      it 'raises error and not saved' do
        post = Post.new({
          user_id: @user.id,
          content: 'a' * 1001,
          attachment_url: '/public/abc.jpg',
          hashtags_str: "['#COMPFEST13', '#TechToElevate']",
        })

        expect{ post.save() }.to(raise_error(StandardError, /1000/))
      end
    end

    context 'given hashtags_str is not an array' do
      it 'raises error and not saved' do
        post = Post.new({
          user_id: @user.id,
          content: 'a content',
          attachment_url: '/public/abc.jpg',
          hashtags_str: "'#COMPFEST13'",
        })

        expect{ post.save() }.to(raise_error(StandardError, /array/))
      end
    end

    context 'given hashtags_str is not a valid array' do
      it 'raises error and not saved' do
        post = Post.new({
          user_id: @user.id,
          content: 'a content',
          attachment_url: '/public/abc.jpg',
          hashtags_str: "['#COMPFEST13', '#TechToElevate'",
        })

        expect{ post.save() }.to(raise_error(StandardError, /array/))
      end
    end

    context 'given hashtags_str is a valid array of integer' do
      it 'raises error and not saved' do
        post = Post.new({
          user_id: @user.id,
          content: 'a content',
          attachment_url: '/public/abc.jpg',
          hashtags_str: "[1, 2, 3]",
        })

        expect{ post.save() }.to(raise_error(StandardError, /string/))
      end
    end

    context 'given hashtags_str is a valid array of string but not started with #' do
      it 'raises error and not saved' do
        post = Post.new({
          user_id: @user.id,
          content: 'a content',
          attachment_url: '/public/abc.jpg',
          hashtags_str: "['#COMPFEST13', 'TechToElevate']",
        })

        expect{ post.save() }.to(raise_error(StandardError, /hashtag/))
      end
    end
  end

  
end
