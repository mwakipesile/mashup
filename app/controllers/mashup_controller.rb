require 'yaml'
require 'bcrypt'
require 'pry'
# Load up all helpers first (NB)
#Dir[File.dirname(__FILE__) + "/helpers/*.rb"].each do |file| 
#  require file
#end

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
  use ImagesController
  use VoteController

  get('/') { redirect('/matchup') }

  run! if __FILE__ == $0
end
