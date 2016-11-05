class VoteController < ApplicationController
  get '/matchup' do
    @image_id, @image_id2 = Matchup.pair
    redirect('/no_matchups') if @image_id.nil? || @image_id2.nil?
    @image, @image2 = Image.fetch(@image_id, @image_id2)
    @rating, @rating2 = Rating.fetch(@image_id, @image_id2)
    erb :matchup
  end

  post '/vote' do
    winner_id = params[:winner]
    loser_id = params[:loser]
    Rating.update(winner_id, loser_id)
    redirect '/matchup'
  end

  get('/no_matchups') { erb :no_matchups}
end