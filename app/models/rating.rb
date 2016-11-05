class Rating
  extend Models::FileHelpers
  RATINGS_PATH = file_path('ratings.yml')
  INITIAL_RATING = 1600
  K = 24

  class << self
    def initial(id)
      ratings = load_data(RATINGS_PATH)
      ratings[id] = { 'rating' => INITIAL_RATING, 'match_count' => 0 }
      save(ratings, RATINGS_PATH)
    end

    def update(winner_id, loser_id)
      @ratings = load_data(RATINGS_PATH)
      @winner_id = winner_id.to_i
      @loser_id = loser_id.to_i
      update_ratings
      update_match_count
      save(@ratings, RATINGS_PATH)
    end

    def update_ratings
      @loser_rating = @ratings[@loser_id]['rating'] || INITIAL_RATING
      @winner_rating = @ratings[@winner_id]['rating'] || INITIAL_RATING

      winner_new_rating, loser_new_rating = calculate_ratings
      @ratings[@loser_id]['rating'] = loser_new_rating
      @ratings[@winner_id]['rating'] = winner_new_rating
    end

    def calculate_ratings
      winner_tr = 10**(@winner_rating/400.0)
      loser_tr = 10**(@loser_rating/400.0)

      winner_ev = winner_tr / (winner_tr + loser_tr)
      elo = (K*(1 - winner_ev)).round(2)

      [@winner_rating + elo, @loser_rating - elo]
    end

    def update_match_count
      @ratings[@winner_id]['match_count'] += 1
      @ratings[@loser_id]['match_count'] += 1
    end

    def fetch(*ids)
      ratings_data = load_data(RATINGS_PATH)

      ratings = ids.each_with_object([]) do |id, ratings_arr|
        ratings_arr << ratings_data[id.to_i]['rating'].round(2)
      end

      ratings.size > 1 ? ratings : ratings.first
    end
  end
end
