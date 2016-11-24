class ImagesController < ApplicationController
  get('/files/upload') { erb :upload }

  post '/files/upload' do
    user_id = session[:username] || request.ip
    file = params[:file]
    # name = params[:name]
    @image = Image.new(file, user_id)
    @image.upload
    #Matchup.submit(@image.id)

    redirect('/')
  end

  get '/images/top' do
    @top_images = Image.fetch(*Rating.top_image_ids(20))
    erb :leaderboard
  end

  get '/images/:filename' do |filename|
    @image = filename
    erb :image
  end
end