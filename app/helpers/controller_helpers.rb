# Controller module
module Controller
  # Controller helpers
  module Helpers
    def flash_message(key, var = nil, session_key = :message)
      session[session_key] ||= Message.fetch(key, var)
    end
  end
end
