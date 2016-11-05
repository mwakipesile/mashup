class Matchup
  extend Models::FileHelpers

  IMAGE_DATA_PATH = file_path('images.yml')
  MATCHUPS_PATH = file_path('matchups.yml')

  class << self
    def submit(new_id)
      ids = load_data(IMAGE_DATA_PATH).keys
      Rating.initial(new_id)

      return if ids.size < 2

      matchups = load_data(MATCHUPS_PATH)
      (ids.first...ids.last).each { |id| matchups << [new_id, id] }

      save(matchups, MATCHUPS_PATH)
    end

    def pair
      matchup = load_data(MATCHUPS_PATH).sample
      random_order = rand(2)
      random_order.zero? ? matchup : matchup.reverse
    end
  end
end