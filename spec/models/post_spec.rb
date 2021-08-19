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
          hashtags: ['#COMPFEST13', '#TechToElevate'],
        })
        post.save()

        raw_data = db_client.query("
          SELECT COUNT(*) AS count
          FROM posts
        ")
        num_of_posts = raw_data.first['count']

        expect(num_of_posts).to(eq(1))
      end

      it 'populates created_at and updated_at field' do
        post = Post.new({
          user_id: @user.id,
          content: 'this is a content',
          attachment_url: '/public/abc.jpg',
          hashtags: ['#COMPFEST13', '#TechToElevate'],
        })

        expect(post.created_at).to(be_nil())
        expect(post.updated_at).to(be_nil())

        post.save()

        expect(post.created_at).not_to(be_nil())
        expect(post.updated_at).not_to(be_nil())

      end
    end

    context 'given valid data and try to save twice' do
      it 'raises error and only saved once' do
        post = Post.new({
          user_id: @user.id,
          content: 'this is a content',
          attachment_url: '/public/abc.jpg',
          hashtags: ['#COMPFEST13', '#TechToElevate'],
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
          hashtags: ['#COMPFEST13', '#TechToElevate'],
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
          hashtags: ['#COMPFEST13', '#TechToElevate'],
        })

        expect{ post.save() }.to(raise_error(StandardError, /1000/))
      end
    end

    context 'given hashtags is not an array' do
      it 'raises error and not saved' do
        post = Post.new({
          user_id: @user.id,
          content: 'a content',
          attachment_url: '/public/abc.jpg',
          hashtags: "#COMPFEST13",
        })

        expect{ post.save() }.to(raise_error(StandardError, /array/))
      end
    end

    context 'given hashtags is not a valid array' do
      it 'raises error and not saved' do
        post = Post.new({
          user_id: @user.id,
          content: 'a content',
          attachment_url: '/public/abc.jpg',
          hashtags: "['#COMPFEST13', '#TechToElevate'",
        })

        expect{ post.save() }.to(raise_error(StandardError, /array/))
      end
    end

    context 'given hashtags is a valid array of integer' do
      it 'raises error and not saved' do
        post = Post.new({
          user_id: @user.id,
          content: 'a content',
          attachment_url: '/public/abc.jpg',
          hashtags: [1, 2, 3],
        })

        expect{ post.save() }.to(raise_error(StandardError, /string/))
      end
    end

    context 'given hashtags is a valid array of string but not started with #' do
      it 'raises error and not saved' do
        post = Post.new({
          user_id: @user.id,
          content: 'a content',
          attachment_url: '/public/abc.jpg',
          hashtags: ['#COMPFEST13', 'TechToElevate'],
        })

        expect{ post.save() }.to(raise_error(StandardError, /hashtag/))
      end
    end
  end

  describe '.all' do
    context 'given 2 post instances in db' do
      it 'returns the 2 posts' do
        db_client.query("
          INSERT INTO posts(user_id, content, attachment_url, hashtags_str) VALUES
            (#{@user.id}, 'content', '', '[]')
        ")

        db_client.query("
          INSERT INTO posts(user_id, content, attachment_url, hashtags_str) VALUES
            (#{@user.id}, 'another content', '', '[]')
        ")

        expect(Post.all().size).to(eq(2))
      end
    end
  end

  describe '.get_by_id' do
    context 'given existing post id' do
      it 'returns the corresponding post' do
        db_client.query("
          INSERT INTO posts(user_id, content, attachment_url, hashtags_str) VALUES
            (#{@user.id}, 'my content', '', '[]')
        ")
        post_id = db_client.last_id

        post = Post.get_by_id(post_id)
        expect(post.content).to(eq('my content'))
      end
    end

    context 'given post id does not exist in db' do
      it 'raises error' do
        expect{ Post.get_by_id(123) }.to(raise_error(StandardError, /not found/))
      end
    end
  end

  describe '#==' do
    context 'given all same attributes' do
      it 'returns true' do
        db_client.query("
          INSERT INTO posts(user_id, content, attachment_url, hashtags_str) VALUES
            (#{@user.id}, 'content', '', '[]')
        ")
        post_id = db_client.last_id

        post1 = Post.get_by_id(post_id)
        post2 = Post.get_by_id(post_id)

        expect(post1 == post2).to(be(true))
      end
    end
  end
end
