class AuthenticationMailer < ApplicationMailer
  def password_reset_email(user)
    token = Token.new
    token.user = user
    token.tokentype = Token::TYPES[:password_reset]
    token.save!

    @token = token
    @user = user

    mail(to: @user.email, subject: "Reset your Aardbei-password")
  end

  def password_confirm_email(user)
    token = Token.new
    token.user = user
    token.tokentype = Token::TYPES[:account_confirmation]
    token.save!

    @token = token
    @user = user

    mail(to: @user.email, subject: "Confirm your Aardbei-account")
  end
end
