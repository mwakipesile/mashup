class Matchup
  extend Model::FileHelpers

  class << self
    def submit(new_id, contest_id)
      @image_data_path = data_path('images.yml', contest_id)
      @matchup_ids_path = data_path('matchup_ids.yml', contest_id)
      @matchups_path = data_path('matchups.yml', contest_id)
      
      @matchups = load_data(@matchups_path) || []
      @matchup_ids = load_data(@matchup_ids_path) || []

      ids = load_data(@image_data_path)
      new_id = new_id.to_i
      ids ? ids << new_id : ids = [new_id]
      save(ids, @image_data_path)

      Rating.initial(new_id, contest_id)

      old_size = @matchups.size
      ids[0...-1].each { |id| @matchups << [new_id, id] }

      current_size = @matchups.size

      @matchup_ids.concat([*old_size...current_size].shuffle)
      @contest_id = contest_id

      save_matchup_ids
      update_matchup_sets(old_size, current_size)
      save(@matchups, @matchups_path)
    end

    def path(filename, contest_id)
      file_path(File.join(contest_id, filename))
    end

    def pair(user_id, contest_id = '')
      @contest_id = contest_id
      @matchups = load_data(path('matchups.yml', contest_id))

      return unless @matchups &&  @matchups.size > 0
      @matchup_ids_path = path('matchup_ids.yml', contest_id)
      @matchup_ids = load_data(@matchup_ids_path)

      @voters_path = path('voters.yml', contest_id)
      @voters = load_data(@voters_path) || {}

      set_new_voter(user_id) if new_voter?(user_id)

      set_voter_matchup_ids(user_id) if voter_matchup_ids(user_id).empty?
      curr_matchup_ids = voter_matchup_ids(user_id)
      return if curr_matchup_ids.empty?
      
      matchup_id = curr_matchup_ids.delete_at(rand(0...curr_matchup_ids.size))
      matchup = @matchups[matchup_id]

      save(@voters, @voters_path)

      random_order = rand(2)
      random_order.zero? ? matchup : matchup.reverse
    end

    def new_voter?(user_id)
      !@voters[user_id]
    end

    def set_new_voter(user_id)
      set_matchup_ids if @matchup_ids.empty?
      @id_sets_path = path('matchup_id_sets.yml', @contest_id)
      id_sets = load_data(@id_sets_path)
      @voters[user_id] = { 'current_matchup_ids' => id_sets[0] }
      @voters[user_id]['current_matchups_set_id'] = 0
    end

    def set_voter_matchup_ids(user_id)
      id_sets = load_data(@id_sets_path)
      set_id = @voters[user_id]['current_matchups_set_id']

      return if set_id == id_sets.keys.max
      @voters[user_id]['current_matchups_set_id'] = set_id + 1
      @voters[user_id]['current_matchup_ids'] = id_sets[set_id + 1]
    end

    def voter_matchup_ids(user_id)
      @voters[user_id]['current_matchup_ids']
    end

    def delete_voter(user_id, contest_id)
      voters_path = path('voters.yml', contest_id)
      @voters = load_data(voters_path)
      @voters.delete(user_id)
      save(@voters, voters_path)
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
      save(@matchup_ids, @matchup_ids_path)
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

      save(sets, @matchup_id_sets)
    end

    def update_matchup_sets(start_idx, size)
      id_sets_path = path('matchup_id_sets.yml', @contest_id)
      id_sets = load_data(id_sets_path) || {}
      i = 0

      (start_idx...size).each do |idx|
        id = @matchup_ids[idx]
        id_sets[i] ? id_sets[i] << id : id_sets[i] = [id]
        i += 1
      end

      save(id_sets, id_sets_path)
    end
  end
end
