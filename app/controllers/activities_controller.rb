class ActivitiesController < ApplicationController
  include GroupsHelper
  include ActivitiesHelper
  before_action :set_activity_and_group, only: [:show, :edit, :update, :destroy, :presence, :change_organizer]
  before_action :set_group,            except: [:show, :edit, :update, :destroy, :presence, :change_organizer]
  before_action :require_membership!
  before_action :require_leader!, only: [:mass_new, :mass_create, :new, :create, :destroy]
  before_action :require_organizer!, only: [:edit, :update, :change_organizer]

  # GET /groups/:id/activities
  # GET /activities.json
  def index
    @activities = @group.activities
      .where('start > ?', Time.now)
      .order(start: :asc)
      .paginate(page: params[:page], per_page: 25)
  end

  # GET /activities/1
  # GET /activities/1.json
  def show
    @participants = @activity.participants
      .joins(:person)
      .order(attending: :desc)
      .order('people.first_name ASC')
    @organizers = @activity.participants
      .joins(:person)
      .where(is_organizer: true)
      .order('people.first_name ASC')
      .map{|p| p.person.full_name}
      .join(', ')
    @ownparticipant = @activity.participants
      .find_by(person: current_person)
    @counts = @activity.state_counts
    @num_participants = @counts.values.sum
  end

  # GET /activities/new
  def new
    @activity = Activity.new
  end

  # GET /activities/1/edit
  def edit
    @non_organizers = @activity.participants.where(is_organizer: [false, nil])
    @organizers = @activity.organizers

    @non_organizers_options = @non_organizers.map{|p| [p.person.full_name, p.id] }
    @organizers_options     =     @organizers.map{|p| [p.person.full_name, p.id] }

    @non_organizers_options.sort!
    @organizers_options.sort!
  end

  # POST /activities
  # POST /activities.json
  def create
    @activity = Activity.new(activity_params)
    @activity.group = @group

    respond_to do |format|
      if @activity.save
        format.html {
          redirect_to group_activity_url(@group, @activity)
          flash_message(:info, I18n.t('activities.created'))
        }
        format.json { render :show, status: :created, location: @activity }
      else
        format.html { render :new }
        format.json { render json: @activity.errors, status: :unprocessable_entity }
      end
    end
  end

  # Change organizer state for a Participant
  def change_organizer
    @activity = Activity.find(params[:activity_id])
    @participant = @activity.participants.find(params[:participant_id])
    @participant.is_organizer = params[:new_state]
    @participant.save

    if params[:new_state] == "true"
      message = I18n.t('activities.organizers.added', name: @participant.person.full_name)
    else
      message = I18n.t('activities.organizers.removed', name: @participant.person.full_name)
    end
    flash_message(:success, message)

    redirect_to edit_group_activity_path(@group, @activity)
  end

  # PATCH/PUT /activities/1
  # PATCH/PUT /activities/1.json
  def update
    respond_to do |format|
      if @activity.update(activity_params)
        format.html {
          redirect_to group_activity_url(@group, @activity)
          flash_message(:info, I18n.t('activities.updated'))
        }
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
      format.html {
        redirect_to group_activities_url(@group)
        flash_message(:info, 'Activity was successfully destroyed.')
      }
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
    if params[:person_id].to_i != current_person.id && !@activity.may_change?(current_person)
      head :forbidden
      return
    end

    if @activity.deadline && @activity.deadline < Time.now && !@activity.may_change?(current_person)
      head :locked
      return
    end

    if params[:participant]
      params[:notes] = params[:participant][:notes]
    end
    participant.update_attributes(params.permit(:notes, :attending))
    head :no_content
  end

  def mass_new
  end

  def mass_create
    require 'csv'
    uploaded_io = params[:spreadsheet]
    result = Activity.from_csv(uploaded_io.read, @group)

    result.each do |a|
      a.save!
    end

    flash_message(:success, I18n.t('activities.mass_imported', count: result.count))
    redirect_to group_activities_path(@group)
  end

  private
    # The Activity's group takes precedence over whatever's in the URL, set_group not required (and can be mislead)
    def set_activity_and_group
      @activity = Activity.find(params[:id] || params[:activity_id])
      @group = @activity.group
    end

    def set_group
      @group = Group.find(params[:group_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def activity_params
      params.require(:activity).permit(:name, :description, :location, :start, :end, :deadline)
    end
end
