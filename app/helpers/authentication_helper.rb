module AuthenticationHelper
  # Create a new Session and set the relevant cookies.
  def log_in(user, remember, new_session = true)
    reset_session

    expiry = 6.hours.since
    session[:user_id] = user.id
    session[:expires] = expiry

    return unless new_session

    if remember == 1
      token = Session.new_token
      expiry = 1.year.since
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
    else
      session[:session_id] = s.id
    end
  end

  # Determine whether the user is logged in, and if so, disable the Session, then flush session cookies.
  def log_out(session_broken: false)
    if !session_broken && logged_in? && @user_session
      user_session

      @user_session.update!(active: false)
    end

    cookies.delete(:user_id)
    cookies.delete(:remember_token)
    cookies.delete(:session_id)
    reset_session
  end

  # Determine whether the current request is from a user with a non-expired session.
  # Makes @user_session available as a side effect if the user is not.
  def logged_in?
    # Case 1: User has an active session inside the cookie.
    # We verify that the session hasn't expired yet.
    if session[:user_id] && session[:expires]&.to_datetime&.future?

      user_session

      return false if !@user_session&.active || @user_session&.expires&.past?

      true

    else
      # Case 2: User is returning and has a remember token saved.
      # We get the Session, check the token and expiry, and log the user in.
      if cookies.signed.permanent[:remember_token] && cookies.signed.permanent[:user_id] &&
         cookies.signed.permanent[:session_id]

        user_session

        return false if @user_session.nil? || @user_session.remember_digest.nil?

        session_password = BCrypt::Password.new @user_session.remember_digest

        if @user_session.expires.future? &&
           session_password == cookies.signed.permanent[:remember_token]
          log_in @user_session.user, false, false
          return true
        end

        return false
      end

      false
    end
  end

  # Get the Session object representing the current user's session.
  def user_session
    if @user_session
      @user_session
    else
      id = cookies.signed.permanent[:session_id] || session[:session_id]
      @user_session ||= Session.find_by(id: id)
    end

    # Edge case if a session no longer exists in the database
    log_out(session_broken: true) unless @user_session
  end

  def current_user
    user_session
    @user_session&.user
  end

  def current_person
    current_user&.person
  end

  def require_login!
    unless logged_in?
      flash_message(:warning, I18n.t('authentication.login_required'))
      redirect_to controller: 'authentication', action: 'login_form'
      return false
    end

    Raven.user_context(
      user_firstname: current_person.first_name
    )
    true
  end

  def require_admin!
    return if current_person.is_admin?

    flash_message(:danger, I18n.t('authentication.admin_required'))
    redirect_to dashboard_home_path
  end
end
