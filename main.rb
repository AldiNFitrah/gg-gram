require 'json'

require 'sinatra'
require 'sinatra/namespace'
require 'sinatra/reloader' if development?

require './controllers/user_controller.rb'


class GgGramApp < Sinatra::Base

  register Sinatra::Namespace

  set :bind, "0.0.0.0"

  before do
    content_type 'application/json'
  end

  namespace '/api' do

    namespace '/users' do
      post '' do
        UserController.create(params)
      end
    end
  end

  run! if __FILE__ == $0
end
