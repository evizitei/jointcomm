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
      params['user']['username'] && params['user']['password']
    end

    def authenticate!
      user = User.first(username: params['user']['username'])
      puts "USER IS: #{user.inspect}"
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
    flash[:success] = env['warden'].message
    if session[:return_to].nil?
      redirect '/'
    else
      redirect session[:return_to]
    end
  end

  get '/auth/logout' do
    env['warden'].logout
    flash[:success] = 'Logged Out'
    redirect '/'
  end

  post '/auth/unauthenticated' do
    session[:return_to] = env['warden.options'][:attempted_path]
    flash[:error] = env['warden'].message || "Not logged in, or login failed"
    redirect '/auth/login'
  end

  get '/dispatches' do
    env['warden'].authenticate!
    @current_user = env['warden'].user
    erb :dispatches
  end
end


