module Controller
  module UserHelpers
    def encrypt(password)
      BCrypt::Password.create(password)
    end

    def check?(password, encrypted_password)
      BCrypt::Password.new(encrypted_password) == password
    end

    def invalid_username(username)
      users = User.all
      return flash_message('username_too_short') if username.size < 2
      return flash_message('username_invalid_chars') if username =~ /\W/
      return flash_message('username_taken') if users[username]
    end

    def invalid_password(password, password2)
      return flash_message('password_too_short') if password.size < 4
      return flash_message('password_invalid_chars') unless password =~ /\w+/
      return flash_message('passwords_dont_match') if password != password2
    end

    def signed_in?
      !!session[:username]
    end

    def admin?
      session[:username] && session[:username].casecmp('admin').zero?
    end

    def redirect_with_message(route, *message)
      flash_message(*message)
      redirect(route)
    end

    def redirect_unauthorized_user(message = 'restricted')
      redirect_with_message(request.referrer, message) unless signed_in?
    end

    def redirect_logged_in_user
      redirect_with_message(request.referrer, 'signed_in') if signed_in?
    end
  end
end
