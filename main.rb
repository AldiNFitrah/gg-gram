require 'json'

require 'sinatra'
require 'sinatra/namespace'
require 'sinatra/reloader' if development?

require './controllers/comment_controller.rb'
require './controllers/hashtag_controller.rb'
require './controllers/post_controller.rb'
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

      post '/:user_id/post' do
        PostController.create(params)
      end
    end

    namespace '/posts' do
      get '' do
        PostController.list(params)
      end

      post '/:post_id/comment' do
        CommentController.create(params)
      end
    end

    namespace '/hashtags' do
      get '/trending' do
        HashtagController.get_trending(5)
      end
    end
  end

  run! if __FILE__ == $0
end
