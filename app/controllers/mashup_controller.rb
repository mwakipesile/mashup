require 'yaml'
require 'bcrypt'
require 'pry'
require 'sinatra/base'
require 'sinatra/reloader'
require 'sinatra/content_for'
require 'tilt/erubis'

# Load up all helpers first (NB)
Dir[File.dirname(File.dirname(__FILE__)) + '/helpers/*.rb'].each do |file|
  require file
end

# Load up all models next
Dir[File.dirname(File.dirname(__FILE__)) + '/models/*.rb'].each do |file|
  require file
end

# Load up all controllers last
Dir[File.dirname(__FILE__) + '/*.rb'].each do |file|
  require file
end

# Main class/app's entry point
class MashupController < ApplicationController
  # middleware will run before filters
  # Can also be ran using "use" in config.ru file.
  use UserController
  use ImagesController
  use VoteController
  use ContestsController
  use DashboardController

  # Permanently redirect URL with trailing "/" to URL without it
  before(%r{/(.+)/$}) { |path| redirect(path, 301) }

  get('/') { redirect('/contests') }

  run! if __FILE__ == $PROGRAM_NAME
end
