class ApiController < ActionController::Base
  include AuthenticationHelper

  before_action :api_require_authentication!, except: [:status]

  def status
    @message = "Ok"
    render 'api/ok'
  end

  protected
  def api_require_authentication!
    if !is_logged_in?
      head :unauthorized
    end
  end

  def api_require_admin!
    if !current_person.is_admin?
      @message = I18n.t('authentication.admin_required')
      render 'api/error', status: :forbidden
    end
  end

  # Require user to be a member of group OR admin, requires @group set
  def require_membership!
    if !current_person.groups.include?(@group) && !current_person.is_admin?
      @message = I18n.t('authentication.membership_required')
      render 'api/error', status: :forbidden
    end
  end
end
