require './db/mysql_connector.rb'
require './models/comment.rb'
require './models/post.rb'
require './models/user.rb'


describe Comment do

  db_client = MySqlClient.instance()

  before(:each) do
    @user = User.new({
      username: 'username',
      email: 'abc@abc.com',
      bio_description: 'this is bio',
    })
    @user.save()

    @post = Post.new({
      username: 'username',
      email: 'abc@abc.com',
      bio_description: 'this is bio',
    })
    @post = Post.new({
      user_id: @user.id,
      content: 'post content',
      attachment_url: '',
      hashtags_str: '[]',
    })
    @post.save()
  end

  describe '#save' do
    context 'given valid data' do
      it 'saved' do
        comment = Comment.new({
          user_id: @user.id,
          post_id: @post.id,
          content: 'this is a content',
          attachment_url: '/public/abc.jpg',
          hashtags_str: "['#COMPFEST13', '#TechToElevate']",
        })
        comment.save()

        raw_data = db_client.query("
          SELECT COUNT(*) AS count
          FROM comments
        ")
        num_of_comments = raw_data.first['count']

        expect(num_of_comments).to(eq(1))
      end
    end

    context 'given valid data and try to save twice' do
      it 'raises error and only saved once' do
        comment = Comment.new({
          user_id: @user.id,
          post_id: @post.id,
          content: 'this is a content',
          attachment_url: '/public/abc.jpg',
          hashtags_str: "['#COMPFEST13', '#TechToElevate']",
        })
        comment.save()

        comment.content = 'new content'
        expect{ comment.save() }.to(raise_error(StandardError, /saved/))
      end
    end

    context 'given unknown user_id' do
      it 'raises error and not saved' do
        comment = Comment.new({
          user_id: 54125,
          post_id: @post.id,
          content: 'this is a content',
          attachment_url: '/public/abc.jpg',
          hashtags_str: "['#COMPFEST13', '#TechToElevate']",
        })

        expect{ comment.save() }.to(raise_error(StandardError, /user/))
      end
    end

    context 'given unknown post_id' do
      it 'raises error and not saved' do
        comment = Comment.new({
          user_id: @user.id,
          post_id: 423432,
          content: 'this is a content',
          attachment_url: '/public/abc.jpg',
          hashtags_str: "['#COMPFEST13', '#TechToElevate']",
        })

        expect{ comment.save() }.to(raise_error(StandardError, /post/))
      end
    end

    context 'given content is longer than 1000 characters' do
      it 'raises error and not saved' do
        comment = Comment.new({
          user_id: @user.id,
          post_id: @post.id,
          content: 'a' * 1001,
          attachment_url: '/public/abc.jpg',
          hashtags_str: "['#COMPFEST13', '#TechToElevate']",
        })

        expect{ comment.save() }.to(raise_error(StandardError, /1000/))
      end
    end

    context 'given hashtags_str is not an array' do
      it 'raises error and not saved' do
        comment = Comment.new({
          user_id: @user.id,
          post_id: @post.id,
          content: 'a content',
          attachment_url: '/public/abc.jpg',
          hashtags_str: "'#COMPFEST13'",
        })

        expect{ comment.save() }.to(raise_error(StandardError, /array/))
      end
    end

    context 'given hashtags_str is not a valid array' do
      it 'raises error and not saved' do
        comment = Comment.new({
          user_id: @user.id,
          post_id: @post.id,
          content: 'a content',
          attachment_url: '/public/abc.jpg',
          hashtags_str: "['#COMPFEST13', '#TechToElevate'",
        })

        expect{ comment.save() }.to(raise_error(StandardError, /array/))
      end
    end

    context 'given hashtags_str is a valid array of integer' do
      it 'raises error and not saved' do
        comment = Comment.new({
          user_id: @user.id,
          post_id: @post.id,
          content: 'a content',
          attachment_url: '/public/abc.jpg',
          hashtags_str: "[1, 2, 3]",
        })

        expect{ comment.save() }.to(raise_error(StandardError, /string/))
      end
    end

    context 'given hashtags_str is a valid array of string but not started with #' do
      it 'raises error and not saved' do
        comment = Comment.new({
          user_id: @user.id,
          post_id: @post.id,
          content: 'a content',
          attachment_url: '/public/abc.jpg',
          hashtags_str: "['#COMPFEST13', 'TechToElevate']",
        })

        expect{ comment.save() }.to(raise_error(StandardError, /hashtag/))
      end
    end
  end

  describe '.all' do
    context 'given 2 comment instances in db' do
      it 'returns the 2 comments' do
        db_client.query("
          INSERT INTO comments(user_id, post_id, content, attachment_url, hashtags_str) VALUES
            (#{@user.id}, #{@post.id}, 'content', '', '[]')
        ")

        db_client.query("
          INSERT INTO comments(user_id, post_id, content, attachment_url, hashtags_str) VALUES
            (#{@user.id}, #{@post.id}, 'another content', '', '[]')
        ")

        expect(Comment.all().size).to(eq(2))
      end
    end
  end

  describe '.get_by_id' do
    context 'given existing comment id' do
      it 'returns the corresponding comment' do
        db_client.query("
          INSERT INTO comments(user_id, post_id, content, attachment_url, hashtags_str) VALUES
            (#{@user.id}, #{@post.id}, 'my content', '', '[]')
        ")
        comment_id = db_client.last_id

        comment = Comment.get_by_id(comment_id)
        expect(comment.content).to(eq('my content'))
      end
    end

    context 'given comment id does not exist in db' do
      it 'raises error' do
        expect{ Comment.get_by_id(123) }.to(raise_error(StandardError, /not found/))
      end
    end
  end

  describe '#==' do
    context 'given all same attributes' do
      it 'returns true' do
        db_client.query("
          INSERT INTO comments(user_id, post_id, content, attachment_url, hashtags_str) VALUES
            (#{@user.id}, #{@post.id}, 'content', '', '[]')
        ")
        comment_id = db_client.last_id

        comment1 = Comment.get_by_id(comment_id)
        comment2 = Comment.get_by_id(comment_id)

        expect(comment1 == comment2).to(be(true))
      end
    end
  end
end
