# This server exists simply to authorize this Alfred 2 Workflow on Dropbox
# via OAuth.

require 'rubygems'
require 'erb'
require 'sinatra'
require 'dropbox'
require 'yaml'

configure do
  enable :sessions
end

def exit!
  Process.kill "TERM", Process.pid
end

def oauth_callback
  "#{@env['rack.url_scheme']}://#{request.host_with_port}/"
end


get '/success' do
  erb :success
end

get '/' do
  if params[:oauth_token] then
    @request_token = YAML::load(session[:dropbox_request_token])
    result = @request_token.get_access_token(:oauth_verifier => params[:oauth_token])

    Dropbox.overwrite_settings({
      "access_token" => result.token,
      "access_secret" => result.secret
    })

    erb :success
  else
    consumer = Dropbox::API::OAuth.consumer(:authorize)
    @request_token = consumer.get_request_token

    session[:dropbox_request_token] = YAML::dump(@request_token)

    redirect @request_token.authorize_url(:oauth_callback => oauth_callback)
  end
end

get '/exit' do
  exit!
  'ok'
end
