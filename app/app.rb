require 'yaml'
require 'sinatra/base'
require 'sinatra/reloader' #if development?
require 'sinatra/content_for'
require 'tilt/erubis'
require 'redcarpet'
require 'bcrypt'

class Application < Sinatra::Application
  configure do
    enable :sessions
    set :session_secret, 'password1'
    set :erb, escape_html: true
  end

  get '/' do
    'Hello world!'
  end

  run! if __FILE__ == $0
end