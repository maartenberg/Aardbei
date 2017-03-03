class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  rescue_from ActionController::InvalidAuthenticityToken, with: :invalid_auth_token

  include AuthenticationHelper
  include ApplicationHelper

  private
  def invalid_auth_token
    render text: "You submitted an invalid request! If you got here after clicking a link, it's possible that someone is doing something nasty!", status: 400
  end
end
