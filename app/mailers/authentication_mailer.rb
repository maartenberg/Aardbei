class AuthenticationMailer < ApplicationMailer
  def password_reset_email(user)
    token = Token.new
    token.user = user
    token.tokentype = Token::TYPES[:password_reset]
    token.save!

    @token = token
    @user = user

    mail(to: @user.email, subject: I18n.t('authentication.emails.forgot.subject'))
  end

  def password_confirm_email(user)
    token = Token.new
    token.user = user
    token.tokentype = Token::TYPES[:account_confirmation]
    token.save!

    @token = token
    @user = user

    mail(to: @user.email, subject: I18n.t('authentication.emails.confirm.subject'))
  end
end
