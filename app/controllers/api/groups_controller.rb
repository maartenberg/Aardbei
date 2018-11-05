# Provides API views to read information related to Groups.
# This controller provides two methods to authenticate and authorize a request:
#   - By the Session used to authenticate logged-in users, and
#   - By passing a custom Authorization:-header of the form 'Group :api_key'.
#
# If the API key method is used, the :id parameter is ignored, but still required in the URL.
class Api::GroupsController < ApiController
  has_no_group = [:index]

  # Session-based authentication / authorization filters
  before_action :set_group,           except: has_no_group, unless: 'request.authorization'
  before_action :require_membership!, except: has_no_group, unless: 'request.authorization'
  before_action :api_require_admin!,  only: has_no_group,   unless: 'request.authorization'

  # API key based filter (both authenticates and authorizes)
  before_action :api_auth_token, if: 'request.authorization'

  # GET /api/groups
  def index
    @groups = Group.all
  end

  # GET /api/groups/1
  def show; end

  # GET /api/groups/1/current_activities
  def current_activities
    @activities = @group.current_activities
    render 'api/activities/index'
  end

  # GET /api/groups/1/upcoming_activities
  def upcoming_activities
    @activities = @group.upcoming_activities
    render 'api/activities/index'
  end

  # GET /api/groups/1/previous_activities
  def previous_activities
    @activities = @group.previous_activities
    render 'api/activities/index'
  end

  private

  # Set group from the :id parameter.
  def set_group
    @group = Group.find(params[:id])
  end

  # Authenticate a request by a 'Authorization: Group xxx'-header.
  # Asserts that the client meant to pass a Group API key, and then sets the
  # @group variable from the key's associated group.
  def api_auth_token
    words = request.authorization.split(' ')
    head :unauthorized unless words[0].casecmp('Group').zero?

    @group = Group.find_by api_token: words[1]
    head :unauthorized unless @group
  end
end
