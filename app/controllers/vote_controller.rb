class VoteController < ApplicationController
  post '/vote' do
    winner_id = params[:winner]
    loser_id = params[:loser]
    contest_id = params[:contest]
    Rating.update(winner_id, loser_id, contest_id)
    redirect request.referrer
  end
end