require './db/mysql_connector.rb'
require './models/user.rb'


describe User do

  db_client = MySqlClient.instance()

  describe '#save' do
    context 'given valid data' do
      it 'saved' do
        user = User.new({
          username: 'username',
          email: 'abc@abc.com',
          bio_description: 'this is bio',
        })
        user.save()

        raw_data = db_client.query("
          SELECT COUNT(*) AS count
          FROM users
        ")
        num_of_users = raw_data.first['count']

        expect(num_of_users).to(eq(1))
      end
    end

    context 'given valid data and try to save twice' do
      it 'raises error and only saved once' do
        user = User.new({
          username: 'username',
          email: 'abc@abc.com',
          bio_description: 'this is bio',
        })
        user.save()

        user.email = 'gg@gg.com'
        expect{ user.save() }.to(raise_error(StandardError, /saved/))
      end
    end

    context 'given no username' do
      it 'raises error and not saved' do
        user = User.new({
          email: 'abc@abc.com',
          bio_description: 'this is bio',
        })

        expect{ user.save() }.to(raise_error(StandardError, /username/))
      end
    end

    context 'given username is already used' do
      it 'raises error and not saved' do
        user1 = User.new({
          username: 'username',
          email: 'abc@abc.com',
          bio_description: 'this is bio',
        })
        user2 = User.new({
          username: 'username',
          email: 'def@def.com',
          bio_description: 'this is bio',
        })

        user1.save()

        expect{ user2.save() }.to(raise_error(StandardError, /username/))
      end
    end

    context 'given no email' do
      it 'raises error and not saved' do
        user = User.new({
          username: 'username',
          bio_description: 'this is bio',
        })

        expect{ user.save() }.to(raise_error(StandardError, /email/))
      end
    end

    context 'given email is already used' do
      it 'raises error and not saved' do
        user1 = User.new({
          username: 'username',
          email: 'abc@abc.com',
          bio_description: 'this is bio',
        })
        user2 = User.new({
          username: 'differentusername',
          email: 'abc@abc.com',
          bio_description: 'this is bio',
        })

        user1.save()

        expect{ user2.save() }.to(raise_error(StandardError, /email/))
      end
    end

    context 'given bio description is longer than 1000 characters' do
      it 'raises error and not saved' do
        user = User.new({
          username: 'username',
          email: 'abc@abc.com',
          bio_description: 'b' * 1001,
        })

        expect{ user.save() }.to(raise_error(StandardError, /1000/))
      end
    end
  end

  describe '.all' do
    context 'given 2 user instances in db' do
      it 'returns the 2 users' do
        db_client.query("
          INSERT INTO users(username, email, bio_description) VALUES
            ('uname', 'abc@abc.com', ''),
            ('uname2', 'abcd@def.com', '')
        ")

        expect(User.all().size).to(eq(2))
      end
    end
  end

  describe '.get_by_id' do
    context 'given existing user id' do
      it 'returns the corresponding user' do
        db_client.query("
          INSERT INTO users(username, email, bio_description) VALUES
            ('uname', 'abc@abc.com', '')
        ")
        user_id = db_client.last_id

        user = User.get_by_id(user_id)
        expect(user.username).to(eq('uname'))
        expect(user.email).to(eq('abc@abc.com'))
      end
    end

    context 'given user id does not exist in db' do
      it 'raises error' do
        expect{ User.get_by_id(123) }.to(raise_error(StandardError, /not found/))
      end
    end
  end

  describe '#==' do
    context 'given all same attributes' do
      it 'returns true' do
        db_client.query("
          INSERT INTO users(username, email, bio_description) VALUES
            ('uname', 'abc@abc.com', '')
        ")
        user_id = db_client.last_id

        user1 = User.get_by_id(user_id)
        user2 = User.get_by_id(user_id)

        expect(user1 == user2).to(be(true))
      end
    end
  end
end
