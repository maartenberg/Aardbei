class AuthenticationController < ApplicationController
  before_action :require_login!, only: [:logout_confirm, :logout]
  def login_form
    render layout: 'void'
  end

  def login
    if params[:session][:email].blank? || params[:session][:password].blank?
      flash_message(:warning, I18n.t(:value_required))
      redirect_to action: 'login_form'
    else
      u = User.find_by(email: params[:session][:email])

      if u&.confirmed && u&.authenticate(params[:session][:password])
        log_in(u, params[:session][:remember_me].to_i)

        flash_message(:success, I18n.t(:greeting, name: u.person.first_name))
        redirect_to root_path
      elsif u && !u.confirmed
        flash_message(:warning, I18n.t('authentication.activation_required'))
        redirect_to action: 'login_form'
      else
        flash_message(:danger, I18n.t('authentication.invalid_user_or_pass'))
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
    render text: logged_in?
  end

  def create_password
    person = Person.find_by(email: params[:user][:email])

    unless person
      flash_message(:warning, I18n.t('authentication.unknown_email'))
      redirect_to action: 'create_password_form'
      return
    end

    user = User.find_by(person: person)
    if user&.confirmed
      flash_message(:warning, I18n.t('authentication.already_activated'))
      redirect_to action: 'login'
      return
    end

    unless user
      user = User.new
      user.person = person
      user.email = person.email
      user.password = user.password_confirmation = SecureRandom::urlsafe_base64 32
      user.confirmed = false
      user.save!
    end

    AuthenticationMailer::password_confirm_email(user).deliver_now
    flash_message(:success, I18n.t('authentication.emails.sent'))
    redirect_to action: 'login'
  end

  def forgotten_password_form
    render layout: 'void'
  end

  def forgotten_password
    user = User.find_by(email: params[:password_reset][:email])
    unless user
      flash_message(:danger, I18n.t('authentication.unknown_email'))
      redirect_to action: 'forgotten_password_form'
      return
    end
    AuthenticationMailer::password_reset_email(user).deliver_later
    flash_message(:success, I18n.t('authentication.emails.sent'))
    redirect_to action: 'login'
  end

  def reset_password_form
    token = Token.find_by(token: params[:token], tokentype: Token::TYPES[:password_reset])
    return unless token_valid? token

    render layout: 'void'
  end

  def reset_password
    token = Token.find_by(token: params[:token], tokentype: Token::TYPES[:password_reset])
    return unless token_valid? token

    if params[:password_reset][:password].blank?
      flash_message :warning, I18n.t('authentication.password_blank')
      render 'authentication/reset_password_form', layout: 'void'
      return
    end

    unless params[:password_reset][:password] == params[:password_reset][:password_confirmation]
      flash_message(:warning, I18n.t('authentication.password_repeat_mismatch'))
      redirect_to action: 'reset_password_form', token: params[:token]
      return
    end

    user = token.user
    user.password = params[:password_reset][:password]
    user.password_confirmation = params[:password_reset][:password_confirmation]
    user.save!

    token.destroy!

    flash_message(:success, I18n.t('authentication.password_reset_complete'))
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

    flash_message(:success, I18n.t('authentication.activation_complete'))
    redirect_to action: 'login'
  end

  private

  def session_params
    params.require(:session).permit(:email, :password, :remember_me)
  end

  def token_valid?(token)
    if token.nil?
      flash_message(:warning, I18n.t('authentication.invalid_token'))
      redirect_to action: 'login'
      return false
    end
    if token.expires && (token.expires < DateTime.now)
      flash_message(:warning, I18n.t('authentication.token_expired'))
      redirect_to action: 'login'
      return false
    end
    true
  end
end
