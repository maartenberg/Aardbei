class Api::GroupsController < ApiController
  has_no_group = [:index]

  before_action :set_group, except: has_no_group
  before_action :require_membership!, except: has_no_group
  before_action :api_require_admin!, only: has_no_group

  # GET /api/groups
  def index
    @groups = Group.all
  end

  # GET /api/groups/1
  def show
  end

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
    # Use callbacks to share common setup or constraints between actions.
    def set_group
      @group = Group.find(params[:id])
    end
end
