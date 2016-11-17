class Message
  extend Model::FileHelpers

  LANGUAGE = 'en'.freeze
  MESSAGES_PATH = file_path('mashup_messages.yml').freeze
  MESSAGES = YAML.load_file(MESSAGES_PATH).freeze

  class << self
    def fetch(key, var = nil)
      format(MESSAGES[LANGUAGE][key], var: var).to_s
    end

    def all
      MESSAGES
    end
  end
end