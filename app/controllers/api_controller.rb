class ApiController < ActionController::Base
  include AuthenticationHelper

  before_action :api_require_authentication!, except: [:status]

  def status
    @message = "Ok"
    render 'api/ok'
  end

  protected
  def api_require_authentication!
    return if is_logged_in?

    head :unauthorized
  end

  def api_require_admin!
    return if current_person&.is_admin?

    @message = I18n.t('authentication.admin_required')
    render 'api/error', status: :forbidden
  end

  # Authenticate a request by a 'Authorization: Group xxx'-header.
  # Asserts that the client meant to pass a Group API key, and then sets the
  # @group variable from the key's associated group.
  def api_auth_group_token
    words = request.authorization.split(' ')
    head :unauthorized unless words[0].casecmp('group').zero?

    @group = Group.find_by api_token: words[1]
    head :unauthorized unless @group
  end

  # Require user to be a member of group OR admin, requires @group set
  def require_membership!
    return if current_person&.groups.include?(@group) || current_person&.is_admin?

    @message = I18n.t('authentication.membership_required')
    render 'api/error', status: :forbidden
  end
end
