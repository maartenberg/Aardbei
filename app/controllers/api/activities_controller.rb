class Api::ActivitiesController < ApiController
  before_action :set_activity, only: [:show]
  before_action :require_membership!, only: [:show]
  before_action :api_require_admin!, only: [:index]

  # GET /api/activities
  # GET /api/activities.json
  def index
    @activities = Activity.all
  end

  # GET /api/activities/1
  # GET /api/activities/1.json
  def show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_activity
      @activity = Activity.find(params[:id])
      @group = @activity.group
    end
end
