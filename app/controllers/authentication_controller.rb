class AuthenticationController < ApplicationController
  before_action :require_login!, only: [:logout_confirm, :logout]
  def login_form
    render layout: 'void'
  end

  def login
    if params[:session][:email].blank? || params[:session][:password].blank?
      flash_message(:warning, "You forgot to add value")
      redirect_to action: 'login_form'
    else
      u = User.find_by(email: params[:session][:email])

      if u && u.confirmed && u.authenticate(params[:session][:password])
        log_in(u, params[:session][:remember_me].to_i)

        flash_message(:success, "Hello, #{u.person.full_name}!")
        redirect_to root_path
      elsif u and not u.confirmed
        flash_message(:warning, "Your account has not been activated yet, please confirm using the email you have received.")
        redirect_to action: 'login_form'
      else
        flash_message(:danger, "Invalid username/password combination!")
        redirect_to action: 'login_form'
      end
    end
  end

  def logout_confirm
    render layout: 'void'
  end

  def logout
    log_out
    redirect_to login_path
  end

  def create_password_form
    render layout: 'void'
  end

  def login_status
    render text: is_logged_in?
  end

  def create_password
    person = Person.find_by(email: params[:user][:email])

    if not person
      flash_message(:warning, "That email address is unknown!")
      redirect_to action: 'create_password_form'
      return
    end

    user = User.find_by(person: person)
    if user and user.confirmed
      flash_message(:warning, "Your account has already been activated, please use the login form if you have forgotten your password.")
      redirect_to action: 'login'
      return
    end

    if not user
      user = User.new
      user.person = person
      user.email = person.email
      user.password = user.password_confirmation = SecureRandom::urlsafe_base64 32
      user.confirmed = false
      user.save!
    end

    AuthenticationMailer::password_confirm_email(user).deliver_now
    flash_message(:success, "An email has been sent, check your inbox!")
    redirect_to action: 'login'
  end

  def forgotten_password_form
    render layout: 'void'
  end

  def forgotten_password
    user = User.find_by(email: params[:password_reset][:email])
    if not user
      flash_message(:danger, "That email address is not associated with any user.")
      redirect_to action: 'forgotten_password_form'
      return
    end
    AuthenticationMailer::password_reset_email(user).deliver_later
    flash_message(:success, "An email has been sent, check your inbox!")
    redirect_to action: 'login'
  end

  def reset_password_form
    token = Token.find_by(token: params[:token], tokentype: Token::TYPES[:password_reset])
    if not token_valid? token
      return
    end
    render layout: 'void'
  end

  def reset_password
    token = Token.find_by(token: params[:token], tokentype: Token::TYPES[:password_reset])
    if not token_valid? token
      return
    end

    if not params[:password] == params[:password_confirmation]
      flash_message(:warning, "Password confirmation does not match your password!")
      redirect_to action: 'reset_password_form', token: params[:token]
      return
    end

    user = token.user
    user.password = params[:password_reset][:password]
    user.password_confirmation = params[:password_reset][:password_confirmation]
    user.save!

    token.destroy!

    flash_message(:success, "Your password has been reset, you may now log in.")
    redirect_to action: 'login'
  end

  def confirm_account_form
    token = Token.find_by(token: params[:token], tokentype: Token::TYPES[:account_confirmation])
    return unless token_valid? token

    @user = token.user
    render layout: 'void'
  end

  def confirm_account
    token = Token.find_by(token: params[:token], tokentype: Token::TYPES[:account_confirmation])
    return unless token_valid? token

    user = token.user
    user.password = params[:account_confirmation][:password]
    user.password_confirmation = params[:account_confirmation][:password_confirmation]
    user.confirmed = true
    user.save!

    token.destroy!

    flash_message(:success, "Your account has been confirmed, you may now log in.")
    redirect_to action: 'login'
  end

  private
  def session_params
    params.require(:session).permit(:email, :password, :remember_me)
  end

  def token_valid?(token)
    if token.nil?
      flash_message(:warning, "No valid token specified!")
      redirect_to action: 'login'
      return false
    end
    if token.expires and token.expires < DateTime.now
      flash_message(:warning, "That token has expired, please request a new one.")
      redirect_to action: 'login'
      return false
    end
    true
  end
end
