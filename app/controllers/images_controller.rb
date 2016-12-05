# Images Controller
class ImagesController < ApplicationController
  get('/files/upload') { erb :upload }

  post '/files/upload' do
    user_id = session[:username] || request.ip
    file = params[:file]

    @image = Image.new(file, user_id)
    @image.upload

    redirect('/')
  end

  get '/images/:filename' do |filename|
    @image = filename
    erb :image
  end
end
