# Contest Model
class Contest
  extend Model::FileHelpers

  CONTEST_TEMPLATE_PATH = file_path('contest_template')
  CONTESTS_PATH = file_path('contests.yml')

  def initialize(contest)
    @contest_name = contest
    @contests = self.class.load_data(CONTESTS_PATH) || {}
    @id = contest_id
    create
  end

  def create
    FileUtils.copy_entry(CONTEST_TEMPLATE_PATH, self.class.file_path(@id.to_s))
    @contests[@id] = @contest_name
    self.class.save(@contests, CONTESTS_PATH)
  end

  def contest_id
    return 0 if @contests.empty?
    @contests.keys.max + 1
  end

  class << self
    def running_contests
      load_data(CONTESTS_PATH) || {}
    end

    def fetch(id)
      contests = load_data(CONTESTS_PATH) || {}
      contests[id.to_i]
    end

    def rename(new_name, id)
      @contests = load_data(CONTESTS_PATH)
      @contests[id.to_i] = new_name
      save(@contests, CONTESTS_PATH)
    end
  end
end
