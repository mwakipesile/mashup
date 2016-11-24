require 'yaml'
require 'bcrypt'
require 'pry'
require 'sinatra/base'
require 'sinatra/reloader' #if development?
require 'sinatra/content_for'
require 'tilt/erubis'

# Load up all helpers first (NB)
Dir[File.dirname(File.dirname(__FILE__)) + "/helpers/*.rb"].each do |file| 
  require file
end

# Load up all models next
Dir[File.dirname(File.dirname(__FILE__)) + "/models/*.rb"].each do |file|
  require file
end

# DataMapper.finalize

# Load up all controllers last
Dir[File.dirname(__FILE__) + "/*.rb"].each do |file| 
  require file
end

class MashupController < ApplicationController
  # middleware will run before filters
  # Can also be ran using "use" in config.ru file.
  use UserController
  use ImagesController
  use VoteController
  use ContestsController
  use DashboardController

  get('/') { redirect('/contests') }

  run! if __FILE__ == $0
end
