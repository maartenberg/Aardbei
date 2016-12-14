module AuthenticationHelper
  # Create a new Session and set the relevant cookies.
  def log_in(user, remember, new=true)
    reset_session

    expiry = 6.hours.since
    session[:user_id] = user.id
    session[:expires] = expiry

    if new
      if remember == 1
        token = Session.new_token
        cookies.signed.permanent[:remember_token] = {
          value: token,
          httponly: true
        }
        cookies.signed.permanent[:user_id] = {
          value: user.id,
          httponly: true
        }
      else
        token = nil
      end
      s = Session.create!(
        user: user,
        ip: request.remote_ip,
        expires: expiry,
        remember_digest: token ? Session.digest(token) : nil
      )
      if remember
        cookies.signed.permanent[:session_id] = {
          value: s.id,
          httponly: true
        }
      end
    end
  end

  # Determine whether the user is logged in, and if so, disable the Session, then flush session cookies.
  def log_out
    if is_logged_in?
      get_user_session

      @user_session.update!(active: false)
    end

    cookies.delete(:user_id)
    cookies.delete(:remember_token)
    cookies.delete(:session_id)
    reset_session
  end

  # Determine whether the current request is from a user with a non-expired session.
  # Makes @user_session available as a side effect if the user is not.
  def is_logged_in?
    # Case 1: User has an active session inside the cookie.
    # We verify that the session hasn't expired yet.
    if session[:user_id] && session[:expires].to_time > DateTime.now

      return true

    else
      # Case 2: User is returning and has a remember token saved.
      # We get the Session, check the token and expiry, and log the user in.
      if cookies.signed.permanent[:remember_token] && cookies.signed.permanent[:user_id] &&
          cookies.signed.permanent[:session_id]

        get_user_session

        if @user_session.nil? || @user_session.remember_digest.nil?
          return false
        end

        session_password = BCrypt::Password.new s.remember_digest

        if @user_session.expires > DateTime.now &&
            session_password == cookies.signed.permanent[:remember_token]
          log_in s.user, false, false
          return true
        end

      return false
      end

    return false
    end
  end

  # Get the Session object representing the current user's session.
  def get_user_session
    if @user_session
      @user_session
    else
      @user_session ||= Session.find_by(
        id: cookies.signed.permanent[:session_id]
      )
    end
  end

  def current_user
    get_user_session
    @user_session.user
  end

  def current_person
    current_user.person
  end

  def require_login!
    if !is_logged_in?
      flash[:warning] = "You need to be logged in to do that."
      redirect_to controller: 'authentication', action: 'login_form'
    end
  end

  def require_admin!
    if !current_person.is_admin?
      flash[:danger] = "You need to be an administrator to do that."
      redirect_to '/dashboard'
    end
  end
end
