class ApplicationController < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  configure do
    enable :sessions
    set :session_secret, 'password1'
    set :views, "app/views"
    set :public_dir, "public"
    set :erb, escape_html: true
  end

  helpers Sinatra::ContentFor, Controller::Helpers, Controller::UserHelpers
end
