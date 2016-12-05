# Matchups model
class Matchup
  extend Model::FileHelpers

  class << self
    def submit(new_id, contest_id)
      @contest_id = contest_id
      set_up_data_paths
      load_matchups_data

      new_id = new_id.to_i
      @image_ids = load_data(@image_data_path) || []
      @image_ids << new_id
      save(@image_ids, @image_data_path)

      Rating.initial(new_id, @contest_id)
      create_matchups_for(new_id)
    end

    def set_up_data_paths
      @image_data_path = data_path('images.yml', @contest_id)
      @matchup_ids_path = data_path('matchup_ids.yml', @contest_id)
      @matchups_path = data_path('matchups.yml', @contest_id)
      @matchup_sets_path = data_path('matchup_id_sets.yml', @contest_id)
      @voters_path = data_path('voters.yml', @contest_id)
    end

    def load_matchups_data
      @matchups = load_data(@matchups_path) || []
      @matchup_ids = load_data(@matchup_ids_path) || []
      @matchup_sets = load_data(@matchup_sets_path) || {}
    end

    def create_matchups_for(new_id)
      old_size = @matchups.size
      @image_ids[0...-1].each { |id| @matchups << [new_id, id] }

      current_size = @matchups.size

      @matchup_ids.concat([*old_size...current_size].shuffle)

      save_matchup_ids
      update_matchup_sets(old_size, current_size)
      save(@matchups, @matchups_path)
    end

    def pair(user_id, contest_id = '')
      @user_id = user_id
      @contest_id = contest_id
      set_up_data_paths
      load_matchups_data

      return unless @matchups && !@matchups.empty?

      @voters = load_data(@voters_path) || {}

      set_new_voter if new_voter?
      set_voter_matchup_ids if @voters[@user_id]['current_matchup_ids'].empty?
      a_matchup
    end

    def a_matchup
      matchup_ids = @voters[@user_id]['current_matchup_ids']
      matchup_id = nil

      loop do
        return if matchup_ids.empty?

        matchup_id = matchup_ids.delete_at(rand(0...matchup_ids.size))
        save(@voters, @voters_path)

        matchup = @matchups[matchup_id]
        break if matchup
      end

      [matchup_id, @matchups[matchup_id]]
    end

    def clear(matchup_id, contest_id, removed_image_ids)
      binding.pry
      matchups_path = data_path('matchups.yml', contest_id)
      matchups = load_data(matchups_path)
      image_data_path = data_path('images.yml', contest_id)
      image_ids = load_data(image_data_path)

      return unless matchups && matchups[matchup_id]

      matchups[matchup_id] = nil
      save(matchups, matchups_path)

      removed_image_ids.each { |id| image_ids.delete(id) }
      save(image_ids, image_data_path)
    end

    def new_voter?
      !@voters[@user_id]
    end

    def set_new_voter
      set_matchup_ids if @matchup_ids.empty?
      @voters[@user_id] = { 'current_matchup_ids' => @matchup_sets[0] }
      @voters[@user_id]['current_matchups_set_id'] = 0
    end

    def set_voter_matchup_ids
      @matchup_sets = load_data(@matchup_sets_path)
      set_id = @voters[@user_id]['current_matchups_set_id']

      return if set_id == @matchup_sets.keys.max
      @voters[@user_id]['current_matchups_set_id'] = set_id + 1
      @voters[@user_id]['current_matchup_ids'] = @matchup_sets[set_id + 1]
    end

    def delete_voter(user_id, contest_id)
      voters_path = data_path('voters.yml', contest_id)
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

      save(sets, @matchup_sets)
    end

    def update_matchup_sets(start_idx, size)
      i = 0

      (start_idx...size).each do |idx|
        id = @matchup_ids[idx]
        @matchup_sets[i] ? @matchup_sets[i] << id : @matchup_sets[i] = [id]
        i += 1
      end

      save(@matchup_sets, @matchup_sets_path)
    end
  end
end
