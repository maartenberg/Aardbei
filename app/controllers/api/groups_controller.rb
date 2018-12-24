# Provides API views to read information related to Groups.
# This controller provides two methods to authenticate and authorize a request:
#   - By the Session used to authenticate logged-in users, and
#   - By passing a custom Authorization:-header of the form 'Group :api_key'.
#
# If the API key method is used, the :id parameter is ignored, but still required in the URL.
module Api
  class GroupsController < ApiController
    has_no_group = [:index]

    # Session-based authentication / authorization filters
    before_action :set_group,           except: has_no_group
    before_action :require_membership!, except: has_no_group
    before_action :api_require_admin!,  only:   has_no_group
    skip_before_action :set_group, :require_membership!, :api_require_authentication!, if: 'request.authorization'

    # API key based filter (both authenticates and authorizes)
    before_action :api_auth_group_token, if: 'request.authorization'

    # GET /api/groups
    def index
      @groups = Group.all
    end

    # GET /api/groups/1
    def show; end

    # GET /api/groups/1/current_activities
    def current_activities
      reference = try_parse_datetime params[:reference]
      @activities = @group.current_activities reference

      render 'api/activities/index'
    end

    # GET /api/groups/1/upcoming_activities
    def upcoming_activities
      reference = try_parse_datetime params[:reference]
      @activities = @group.upcoming_activities reference

      render 'api/activities/index'
    end

    # GET /api/groups/1/previous_activities
    def previous_activities
      reference = try_parse_datetime params[:reference]
      @activities = @group.previous_activities reference

      render 'api/activities/index'
    end

    private

    # Set group from the :id parameter.
    def set_group
      @group = Group.find(params[:id])
    end

    # @return [DateTime] the parsed input.
    def try_parse_datetime(input = nil)
      return unless input

      begin
        DateTime.parse input # rubocop:disable Style/DateTime
      rescue ArgumentError
        nil
      end
    end
  end
end
