class AuthenticationController < ApplicationController
  before_action :require_login!, only: [:logout_confirm, :logout]
  def login_form
    render layout: 'void'
  end

  def login
    if params[:session][:email].blank? || params[:session][:password].blank?
      flash[:warning] = "You forgot to add value"
      redirect_to action: 'login_form'
    else
      u = User.find_by(email: params[:session][:email])

      if u && u.authenticate(params[:session][:password])
        log_in(u, params[:session][:remember_me].to_i)

        flash[:success] = "Hello, #{u.person.full_name}!"
        redirect_to root_path
      else
        flash[:danger] = "Invalid username/password combination!"
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
    flash[:danger] = "Not yet implemented."
    redirect_to action: 'login'
  end

  def forgotten_password_form
    render layout: 'void'
  end

  def forgotten_password
    flash[:danger] = "Not yet implemented."
    redirect_to action: 'login'
  end

  def reset_password_form
    token = Token.find_by(token: params[:token], tokentype: Token::TYPES[:password_reset])
    if not password_reset_token_valid? token
      return
    end
    render layout: 'void'
  end

  def reset_password
    token = Token.find_by(token: params[:token], tokentype: Token::TYPES[:password_reset])
    if not password_reset_token_valid? token
      return
    end

    if not params[:password] == params[:password_confirmation]
      flash[:warning] = "Password confirmation does not match your password!"
      redirect_to action: 'reset_password_form', token: params[:token]
      return
    end

    user = token.user
    user.password = params[:password_reset][:password]
    user.password_confirmation = params[:password_reset][:password_confirmation]
    user.save!

    token.destroy!

    flash[:success] = "Your password has been reset, you may now log in."
    redirect_to action: 'login'
  end

  private
  def session_params
    params.require(:session).permit(:email, :password, :remember_me)
  end

  def password_reset_token_valid?(token)
    if token.nil?
      flash[:warning] = "No valid token specified!"
      redirect_to action: 'login'
      return false
    end
    if token.expires and token.expires < DateTime.now
      flash[:warning] = "That token has expired, please request a new one."
      redirect_to action: 'login'
      return false
    end
    true
  end
end
