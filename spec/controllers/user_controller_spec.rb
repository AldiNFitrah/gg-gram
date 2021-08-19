require 'rack/test'

require './controllers/user_controller.rb'
require './main.rb'
require './models/user.rb'
require 'ap'


describe UserController do

  include Rack::Test::Methods

  def app
    return GgGramApp.new
  end

  describe '.create' do
    context 'post valid data via url' do
      before(:each) do
        post('/api/users', params={
          'username'=> 'username',
          'email'=> 'abc@abc.com',
          'bio_description'=> 'this is bio',
        })
      end

      it 'is created' do
        expect(User.all().count()).to(eq(1))
      end

      it 'response the created user' do
        response_body = eval(last_response.body)

        expect(last_response.status).to(eq(201))
        expect(response_body[:id]).to(be_kind_of(Integer))
        expect(response_body).to(include({
          :username => 'username',
          :email => 'abc@abc.com',
          :bio_description => 'this is bio',
        }))
      end
    end
    context 'post data without username via url' do
      before(:each) do
        post('/api/users', params={
          'email'=> 'abc@abc.com',
          'bio_description'=> 'this is bio',
        })
      end

      it 'is not created' do
        expect(User.all().count()).to(eq(0))
      end

      it 'response error' do
        response_body = eval(last_response.body)

        expect(last_response.status).to(eq(400))
        expect(response_body).to(include(:error))
      end
    end
  end
end
