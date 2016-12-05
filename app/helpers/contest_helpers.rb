# Contest module
module Controller
  # Contest helpers
  module ContestHelpers
    def redirect_contest_doesnt_exist
      flash_message('no_contest')
      redirect request.referrer
    end
  end
end
