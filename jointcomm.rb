require 'bundler'
Bundler.require

require './model'

class JointComm < Sinatra::Base
  enable :sessions
  configure :production, :development do
    enable :logging
  end
  register Sinatra::Flash

  use Warden::Manager do |config|
    config.serialize_into_session{|user| user.id }
    config.serialize_from_session{|id| User.get(id) }
    config.scope_defaults :default, strategies: [:password], action: 'auth/unauthenticated'
    config.failure_app = self
  end

  Warden::Manager.before_failure do |env, opts|
    env["REQUEST_METHOD"] = 'POST'
  end

  Warden::Strategies.add(:password) do
    def valid?
      return false unless params && params['user']
      params['user']['username'] && params['user']['password']
    end

    def authenticate!
      user = User.first(username: params['user']['username'])
      if user.nil?
        fail!("The username you entered does not exist")
      elsif user.authenticate(params['user']['password'])
        success!(user)
      else
        fail!("Could not log in")
      end
    end
  end

  get '/' do
    erb :index
  end

  get '/auth/login' do
    erb :login
  end

  post '/auth/login' do
    env['warden'].authenticate!
    flash[:success] = env['warden'].message || "Logged in!"
    if session[:return_to].nil?
      redirect to('/dispatches')
    else
      redirect to(session[:return_to])
    end
  end

  get '/auth/logout' do
    env['warden'].logout
    flash[:success] = 'Logged Out'
    redirect to('/')
  end

  post '/auth/unauthenticated' do
    session[:return_to] = env['warden.options'][:attempted_path]
    flash[:error] = env['warden'].message || "Not logged in, or login failed"
    redirect to('/auth/login')
  end

  get '/dispatches' do
    env['warden'].authenticate!
    @current_user = env['warden'].user
    erb :dispatches
  end
end


