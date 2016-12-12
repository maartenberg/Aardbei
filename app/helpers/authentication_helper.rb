module AuthenticationHelper
  def log_in(user, remember, new=true)
    reset_session

    expiry = 6.hours.since
    session[:user_id] = user.id
    session[:expires] = expiry

    if new
      if remember == 1
        token = Session.new_token
        cookies.signed.permanent[:remember_token] = token
        cookies.signed.permanent[:user_id] = user.id
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
        cookies.signed.permanent[:session_id] = s.id
      end
    end
  end

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

        s = Session.find_by(
          id: cookies.signed.permanent[:session_id]
        )
        if s.nil? || s.remember_digest.nil?
          return false
        end

        session_password = BCrypt::Password.new s.remember_digest

        if s.expires > DateTime.now && session_password == cookies.signed.permanent[:remember_token]
          log_in s.user, false, false
          return true
        end

      return false
      end

    return false

    end
  end

end
