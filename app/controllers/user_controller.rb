# User Controller
class UserController < ApplicationController
  before %r{/users\/sign(?:up|in)} do
    pass if request.get?
    @username = params[:username]
    @password = params[:password]
  end

  get('/users/signup') { erb :signup }

  post '/users/signup' do
    @password2 = params[:password2]
    halt erb(:signup) if invalid_username || invalid_password

    User.create(@username, encrypt(@password))
    session[:username] = @username
    redirect_with_message('/', 'welcome', @username)
  end

  get('/users/signin') { erb :signin }

  post '/users/signin' do
    user = User.fetch(@username)
    password = user['password']
    session[:username] = @username if user && check?(@password, password)

    redirect_with_message('/', 'welcome', @username) if signed_in?

    status(422)
    flash_message('invalid_credentials')
    erb :signin
  end

  post '/users/signout' do
    username = session.delete(:username)
    redirect_with_message(request.referrer, 'goodbye', username)
  end
end
