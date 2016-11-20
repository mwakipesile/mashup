class DashboardController < ApplicationController
  before %r{/(.+)/$} do |path|
    redirect(path)
  end

  before %r{/(dashboard$|dashboard/.*)} do 
    pass if admin?
    redirect_unauthorized_user('admin_only')
  end

  helpers do
    def derb(template, layout = :'dashboard/layout')
      erb(:"dashboard/#{template}", layout: layout)
    end
  end

  get '/dashboard' do
    derb :dashboard
  end

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
    redirect(request.referrer)
  end
end