class ImagesController < ApplicationController
  get('/files/upload') { erb :upload }

  post '/files/upload' do
    user_id = session[:username] || request.ip
    file = params[:file]
    # name = params[:name]
    @image = Image.new(file, user_id)
    @image.upload
    Matchup.submit(@image.id)

    redirect('/')
  end
end