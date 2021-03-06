# Dashboard Controller
class DashboardController < ApplicationController
  before %r{/(dashboard$|dashboard/.*)} do
    pass if admin?
    redirect_unauthorized_user('admin_only')
  end

  helpers do
    def derb(template, layout = :'dashboard/layout')
      erb(:"dashboard/#{template}", layout: layout)
    end
  end

  get('/dashboard') { derb :dashboard }

  get '/dashboard/users' do
    @users = User.all_names
    derb :users
  end

  get '/dashboard/users/:username' do |username|
    @user = username
    derb :user
  end

  post '/dashboard/users/:username/delete' do |username|
    User.delete(username)
    Matchup.delete_voter(username)
    Image.delete_user_images(username)

    session.delete(:username) if session[:username].casecmp(username).zero?
    redirect(request.referrer)
  end

  get '/dashboard/images' do
    @images = Image.all
    derb :images
  end

  post '/dashboard/images/:image_id/delete' do |image_id|
    Image.delete(image_id)

    redirect(request.referrer)
  end
end
