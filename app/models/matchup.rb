class Matchup
  extend Model::FileHelpers

  IMAGE_DATA_PATH = file_path('images.yml').freeze
  MATCHUPS_PATH = file_path('matchups.yml').freeze
  MATCHUP_IDS_PATH = file_path('matchup_ids.yml').freeze
  MATCHUP_ID_SUBSETS_PATH = file_path('matchup_id_sets.yml').freeze
  VOTERS_PATH = file_path('voters.yml').freeze

  @matchup_ids = load_data(MATCHUP_IDS_PATH)
  @matchups = load_data(MATCHUPS_PATH)
  @voters = load_data(VOTERS_PATH)

  class << self
    def submit(new_id)
      ids = load_data(IMAGE_DATA_PATH).keys
      Rating.initial(new_id)
      return if ids.size < 2

      old_size = @matchups.size
      (ids.first...new_id).each { |id| @matchups << [new_id, id] }
      current_size = @matchups.size

      @matchup_ids.concat([*old_size...current_size].shuffle)

      save_matchup_ids
      update_matchup_sets(old_size, current_size)
      save(@matchups, MATCHUPS_PATH)
    end

    def pair(user_id) 
      return unless @matchups &&  @matchups.size > 0       
      set_new_voter(user_id) if new_voter?(user_id)

      set_voter_matchup_ids(user_id) if voter_matchup_ids(user_id).empty?
      curr_matchup_ids = voter_matchup_ids(user_id)
      return if curr_matchup_ids.empty?
      
      matchup_id = curr_matchup_ids.delete_at(rand(0...curr_matchup_ids.size))
      matchup = @matchups[matchup_id]

      save(@voters, VOTERS_PATH)

      random_order = rand(2)
      random_order.zero? ? matchup : matchup.reverse
    end

    def new_voter?(user_id)
      !@voters[user_id]
    end

    def set_new_voter(user_id)
      set_matchup_ids if @matchup_ids.empty?

      id_sets = load_data(MATCHUP_ID_SUBSETS_PATH)
      @voters[user_id] = { 'current_matchup_ids' => id_sets[0] }
      @voters[user_id]['current_matchups_set_id'] = 0
    end

    def set_voter_matchup_ids(user_id)
      id_sets = load_data(MATCHUP_ID_SUBSETS_PATH)
      set_id = @voters[user_id]['current_matchups_set_id']

      return if set_id == id_sets.keys.max
      @voters[user_id]['current_matchups_set_id'] = set_id + 1
      @voters[user_id]['current_matchup_ids'] = id_sets[set_id + 1]
    end

    def voter_matchup_ids(user_id)
      @voters[user_id]['current_matchup_ids']
    end

    def set_matchup_ids
      @matchup_ids = matchup_ids
      save_matchup_ids
      save_matchup_id_sets
    end

    def matchup_ids
      [*0...@matchups.size].shuffle
    end

    def save_matchup_ids
      save(@matchup_ids, MATCHUP_IDS_PATH)
    end

    def save_matchup_id_sets
      sets = {}
      i = 0
      ids = @matchup_ids.dup

      loop do
        (0..i).each do |idx|
          sets[idx] ? sets[idx] << ids.shift : sets[idx] = [ids.shift]
        end
        break if ids.empty?

        i += 1
      end

      save(sets, MATCHUP_ID_SUBSETS_PATH)
    end

    def update_matchup_sets(start_idx, size)
      id_sets = load_data(MATCHUP_ID_SUBSETS_PATH)
      i = 0

      (start_idx...size).each do |idx|
        id = @matchup_ids[idx]
        id_sets[i] ? id_sets[i] << id : id_sets[i] = [id]
        i += 1
      end

      save(id_sets, MATCHUP_ID_SUBSETS_PATH)
    end
  end
end
