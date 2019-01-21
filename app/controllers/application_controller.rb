class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  rescue_from ActionController::InvalidAuthenticityToken, with: :invalid_auth_token

  include AuthenticationHelper
  include ApplicationHelper

  private

  def invalid_auth_token
    render text: I18n.t(:invalid_csrf), status: :bad_request
  end
end
