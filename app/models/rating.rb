# Ratings model
class Rating
  extend Model::FileHelpers

  RATINGS_PATH = file_path('ratings.yml')
  INITIAL_RATING = 1600
  DEFAULT_TOP_COUNT = 5
  K = 24

  class << self
    def load_ratings(contest_id)
      @ratings_path = data_path('ratings.yml', contest_id)
      @ratings = load_data(@ratings_path) || {}
    end

    def initial(id, contest_id)
      load_ratings(contest_id)
      @ratings[id] = { 'rating' => INITIAL_RATING, 'match_count' => 0 }
      save(@ratings, @ratings_path)
    end

    def update(winner_id, loser_id, contest_id)
      @winner_id = winner_id.to_i
      @loser_id = loser_id.to_i

      load_ratings(contest_id)
      update_ratings
      update_match_count
      save(@ratings, @ratings_path)
    end

    def update_ratings
      @loser_rating = @ratings[@loser_id]['rating'] || INITIAL_RATING
      @winner_rating = @ratings[@winner_id]['rating'] || INITIAL_RATING

      winner_new_rating, loser_new_rating = calculate_ratings
      @ratings[@loser_id]['rating'] = loser_new_rating
      @ratings[@winner_id]['rating'] = winner_new_rating
    end

    def calculate_ratings
      winner_tr = 10**(@winner_rating / 400.0)
      loser_tr = 10**(@loser_rating / 400.0)

      winner_ev = winner_tr / (winner_tr + loser_tr)
      elo = (K * (1 - winner_ev)).round(2)

      [@winner_rating + elo, @loser_rating - elo]
    end

    def update_match_count
      @ratings[@winner_id]['match_count'] += 1
      @ratings[@loser_id]['match_count'] += 1
    end

    def fetch(*ids, contest_id)
      load_ratings(contest_id)
      ratings = ids.each_with_object([]) do |id, ratings_arr|
        ratings_arr << @ratings[id.to_i]['rating'].round(2)
      end

      ratings.size > 1 ? ratings : ratings.first
    end

    def top_image_ids(contest_id, n = DEFAULT_TOP_COUNT)
      load_ratings(contest_id)
      @ratings.keys.sort_by { |id| -@ratings[id]['rating'] }.first(n)
    end
  end
end
