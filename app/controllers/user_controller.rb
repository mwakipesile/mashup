class UserController < ApplicationController
  get('/users/signup') { erb :signup }

  post '/users/signup' do
    username = params[:username]
    password = params[:password]
    password2 = params[:password2]

    if invalid_username(username) || invalid_password(password, password2)
      halt erb(:signup)
    end

    User.create(username, encrypt(password))
    session[:username] = username
    redirect_with_message('/', 'welcome', username)
  end

  get('/users/signin') { erb :signin }

  post '/users/signin' do
    username = params[:username]
    password = params[:password]

    user = User.fetch(username)
    session[:username] = username if user && check?(password, user['password'])

    redirect_with_message('/', 'welcome', username) if signed_in?

    status(422)
    flash_message('invalid_credentials')
    erb :signin
  end

  post '/users/signout' do
    username = session.delete(:username)
    redirect_with_message(request.referrer, 'goodbye', username)
  end
end
