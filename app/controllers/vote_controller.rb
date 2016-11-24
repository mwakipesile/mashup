class VoteController < ApplicationController
  get '/matchup' do
    user_id = session[:username] || request.ip
    @image_id, @image_id2 = Matchup.pair(user_id)
    redirect('/no_matchups') if @image_id.nil? || @image_id2.nil?

    @image, @image2 = Image.fetch(@image_id, @image_id2)
    @rating, @rating2 = Rating.fetch(@image_id, @image_id2)

    erb :matchup
  end

  post '/vote' do
    winner_id = params[:winner]
    loser_id = params[:loser]
    contest_id = params[:contest]
    Rating.update(winner_id, loser_id, contest_id)
    redirect request.referrer
  end
end