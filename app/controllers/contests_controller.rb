#Matchup.submit(@image.id)

class ContestsController < ApplicationController
  get '/contests' do
    @contests = Contest.running 
    erb :index
  end

  get '/contests/create' do
    erb :new_contest
  end

  post '/contests/create' do
    contest = params[:contest]
    Contest.new(contest)
    redirect('/contests')
  end

  get '/contests/:contest_id/submit' do |contest_id|
    @contest_id = contest_id
    @user_id = session[:username] || request.ip
    @user_images = Image.user_images(@user_id)
    erb :submission
  end

  post '/contests/:contest_id/submit' do |contest_id|
    image_id = params[:image_id]
    # @user_id = session[:username] || request.ip
    # @user_images = Image.user_images(@user_id)
    Matchup.submit(image_id, contest_id)
    redirect request.referrer
  end

  get '/contests/:contest_id' do |contest_id|
    @contest = Contest.fetch(contest_id)
    return unless @contest
    @top_images = Image.fetch(*Rating.top_image_ids(contest_id)) || []
    @contest_id = contest_id
    
    user_id = session[:username] || request.ip
    @image_id, @image_id2 = Matchup.pair(user_id, contest_id)
    redirect("/contests/#{contest_id}/no_matchups") if @image_id.nil? || @image_id2.nil?

    @image, @image2 = Image.fetch(@image_id, @image_id2)
    @rating, @rating2 = Rating.fetch(@image_id, @image_id2, contest_id)

    erb :matchup
  end

  get('/contests/:contest_id/no_matchups') do |contest_id|
    @contest_id = contest_id
    @top_images = Image.fetch(*Rating.top_image_ids(@contest_id)) || []
    erb :no_matchups
  end
end
