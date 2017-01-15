class ActivitiesController < ApplicationController
  include GroupsHelper
  before_action :set_activity, only: [:show, :edit, :update, :destroy, :presence]
  before_action :set_group
  before_action :require_membership!

  # GET /groups/:id/activities
  # GET /activities.json
  def index
    @activities = @group.activities
  end

  # GET /activities/1
  # GET /activities/1.json
  def show
    @participants = @activity.participants
      .joins(:person)
      .order(attending: :desc)
      .order('people.first_name ASC')
    @counts = @activity.state_counts
    @num_participants = @counts.values.sum
  end

  # GET /activities/new
  def new
    @activity = Activity.new
  end

  # GET /activities/1/edit
  def edit
  end

  # POST /activities
  # POST /activities.json
  def create
    @activity = Activity.new(activity_params)
    @activity.group = @group

    respond_to do |format|
      if @activity.save
        format.html { redirect_to group_activity_url(@group, @activity), notice: 'Activity was successfully created.' }
        format.json { render :show, status: :created, location: @activity }
      else
        format.html { render :new }
        format.json { render json: @activity.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /activities/1
  # PATCH/PUT /activities/1.json
  def update
    respond_to do |format|
      if @activity.update(activity_params)
        format.html { redirect_to group_activity_url(@group, @activity), notice: 'Activity was successfully updated.' }
        format.json { render :show, status: :ok, location: @activity }
      else
        format.html { render :edit }
        format.json { render json: @activity.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /activities/1
  # DELETE /activities/1.json
  def destroy
    @activity.destroy
    respond_to do |format|
      format.html { redirect_to group_activities_url(@group), notice: 'Activity was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # PATCH/PUT /groups/:group_id/activities/:id/presence
  # PATCH/PUT /groups/:group_id/activities/:id/presence.json
  def presence
    participant = Participant.find_by(
      person_id: params[:person_id],
      activity: @activity
    )
    if !@activity.may_change?(current_person)
      render status: :forbidden
    end

    if params[:participant]
      params[:notes] = params[:participant][:notes]
    end
    participant.update_attributes(params.permit(:notes, :attending))
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_activity
      @activity = Activity.find(params[:id])
    end

    def set_group
      @group = Group.find(params[:group_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def activity_params
      params.require(:activity).permit(:public_name, :secret_name, :description, :location, :start, :end, :deadline, :show_hidden)
    end
end
