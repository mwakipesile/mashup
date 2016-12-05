# Contests Controller
class ContestsController < ApplicationController
  before do
    @user_id = session[:username] || request.ip
  end

  before %r{/contests\/(\d+)(?:\/.*)*} do |contest_id|
    @contest_id = contest_id
  end

  before %r{/contests\/(:?\d+)(?:$|\/edit)} do
    pass if request.post?
    @contest = Contest.fetch(@contest_id)
  end

  get '/contests' do
    @contests = Contest.running_contests
    erb :index
  end

  get('/contests/create') { erb :new_contest }

  post '/contests/create' do
    contest = params[:contest]
    Contest.new(contest)
    redirect('/contests')
  end

  get '/contests/:contest_id/submit' do
    @user_images = Image.user_images(@user_id)
    erb :submission
  end

  post '/contests/:contest_id/submit' do
    image_id = params[:image_id]
    Matchup.submit(image_id, @contest_id)
    redirect request.referrer
  end

  get '/contests/:contest_id' do
    redirect_contest_doesnt_exist unless @contest

    @top_images = Image.fetch(*Rating.top_image_ids(@contest_id)) || []

    @image_id, @image_id2 = Matchup.pair(@user_id, @contest_id)
    halt(erb(:no_matchups)) if @image_id.nil? || @image_id2.nil?

    @image, @image2 = Image.fetch(@image_id, @image_id2)
    @rating, @rating2 = Rating.fetch(@image_id, @image_id2, @contest_id)

    erb :contest
  end

  get '/contests/:contest_id/images/top' do
    @top_images = Image.fetch(*Rating.top_image_ids(@contest_id, 20)) || []
    erb :leaderboard
  end

  get('/contests/:contest_id/edit') { erb :edit_contest }

  post '/contests/:contest_id/edit' do
    @updated_name = params[:contest_name]
    @contests = Contest.running_contests

    if @contests.any? { |_, name| name.casecmp(@updated_name).zero? }
      flash_message('duplicate_name')
      halt erb(:edit_contest)
    end

    Contest.rename(@updated_name, @contest_id)
    redirect('/')
  end
end
