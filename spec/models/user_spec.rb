require './db/mysql_connector.rb'
require './models/user.rb'


describe User do

  db_client = MySqlClient.instance()

  describe '#save' do
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

end
