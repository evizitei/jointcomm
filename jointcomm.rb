require 'bundler'
Bundler.require

require 'dotenv'
Dotenv.load

require './config/twilio'
require './twilio_proxy'
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
    erb :main_layout, layout: false do
      erb :index
    end
  end

  get '/auth/login' do
    erb :main_layout, layout: false do
      erb :login
    end
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
    @queued_calls = Call.unassigned
    @active_calls = Call.in_flight
    erb :main_layout, layout: false do
      erb :dispatches
    end
  end

  get '/calls/new' do
    env['warden'].authenticate!
    erb :main_layout, layout: false do
      erb :new_call
    end
  end

  post '/calls/create' do
    env['warden'].authenticate!
    Call.create(params[:call])
    redirect to('/dispatches')
  end

  get "/calls/pick_driver" do
    env['warden'].authenticate!
    @drivers = Driver.all
    @call = Call.get(params[:id])
    erb :main_layout, layout: false do
      erb :calls_pick_driver
    end
  end

  post "/calls/assign" do
    env['warden'].authenticate!
    @call = Call.get(params[:id])
    @driver = Driver.get(params[:driver_id])
    @call.driver_id = @driver.id
    @call.save
    TwilioProxy.send_call_alert(@driver, @call)
    redirect to('/dispatches')
  end

  get "/calls/acknowledge" do
    @call = Call.get(params[:id])
    @call.acknowledged_at = DateTime.now
    @call.save
    TwilioProxy.send_call_clear(@call.driver, @call)
    erb :call_acknowledged
  end

  get "/calls/clear" do
    @call = Call.get(params[:id])
    @call.cleared_at = DateTime.now
    @call.save
    erb :call_cleared
  end

  get '/drivers/index' do
    env['warden'].authenticate!
    @drivers = Driver.all
    erb :main_layout, layout: false do
      erb :drivers
    end
  end

  get '/drivers/new' do
    env['warden'].authenticate!
    erb :main_layout, layout: false do
      erb :new_driver
    end
  end

  post '/drivers/create' do
    env['warden'].authenticate!
    Driver.create(params[:driver])
    redirect to('/drivers/index')
  end
end


