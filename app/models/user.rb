# User model
class User
  extend Model::FileHelpers

  CREDENTIALS_PATH = file_path('users.yml')
  @users = load_data(CREDENTIALS_PATH)

  class << self
    def all
      @users
    end

    def all_names
      all.keys
    end

    def fetch(username)
      @users[username]
    end

    def create(username, password)
      @users[username] = { 'password' => password }
      save(@users, CREDENTIALS_PATH)
    end

    def delete(username)
      @users.delete(username)
      save(@users, CREDENTIALS_PATH)
    end
  end
end
