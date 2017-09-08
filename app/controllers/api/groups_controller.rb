class Api::GroupsController < ApiController
  before_action :set_group, only: [:show]
  before_action :require_membership!, only: [:show]
  before_action :api_require_admin!, only: [:index]

  # GET /api/groups
  # GET /api/groups.json
  def index
    @api_groups = Api::Group.all
  end

  # GET /api/groups/1
  def show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group
      @group = Group.find(params[:id])
    end
end
