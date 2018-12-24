class ActivitiesController < ApplicationController
  include GroupsHelper
  include ActivitiesHelper

  has_activity_id = [
    :show, :edit, :edit_subgroups, :update, :update_subgroups, :destroy,
    :presence, :change_organizer, :create_subgroup, :update_subgroup,
    :destroy_subgroup, :immediate_subgroups, :clear_subgroups
  ]
  before_action :set_activity_and_group, only: has_activity_id
  before_action :set_group,            except: has_activity_id

  before_action :set_subgroup, only: [:update_subgroup, :destroy_subgroup]
  before_action :require_membership!
  before_action :require_leader!, only: [
    :mass_new, :mass_create, :new, :create, :destroy
  ]
  before_action :require_organizer!, only: [
    :edit, :update, :change_organizer, :create_subgroup, :update_subgroup,
    :destroy_subgroup, :edit_subgroups, :update_subgroups, :immediate_subgroups,
    :clear_subgroups
  ]

  # GET /groups/:id/activities
  # GET /activities.json
  def index
    if params[:past]
      @activities = @group.activities
        .where('start < ?', Time.now)
        .order(start: :desc)
        .paginate(page: params[:page], per_page: 25)
    else
      @activities = @group.activities
        .where('start > ?', Time.now)
        .order(start: :asc)
        .paginate(page: params[:page], per_page: 25)
    end
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
    @assignable_subgroups = @activity.subgroups
      .where(is_assignable: true)
      .order(name: :asc)
      .pluck(:name)
    @subgroup_ids = @activity.subgroups
      .order(name: :asc)
      .pluck(:name, :id)
    @subgroup_ids.prepend( [I18n.t('activities.subgroups.filter_nofilter'), 'all'] )
    @subgroup_ids.append( [I18n.t('activities.subgroups.filter_nogroup'), 'withoutgroup'] )
  end

  # GET /activities/new
  def new
    @activity = Activity.new
  end

  # GET /activities/1/edit
  def edit
    set_edit_parameters!
  end

  # GET /activities/1/edit_subgroups
  def edit_subgroups
    @subgroups = @activity.subgroups.order(is_assignable: :desc, name: :asc)

    if @subgroups.none?
      flash_message(:error, I18n.t('activities.errors.cannot_subgroup_without_subgroups'))
      redirect_to group_activity_edit(@group, @activity)
    end

    @subgroup_options = @subgroups.map { |sg| [sg.name, sg.id] }
    @subgroup_options.prepend(['--', 'nil'])

    @participants = @activity.participants
      .joins(:person)
      .where.not(attending: false)
      .order(:subgroup_id)
      .order('people.first_name', 'people.last_name')
  end

  # POST /activities/1/update_subgroups
  def update_subgroups
    Participant.transaction do
      # For each key in participant_subgroups:
      params[:participant_subgroups].each do |k, v|
        # Get Participant, Subgroup
        p = Participant.find_by id: k
        sg = Subgroup.find_by id: v unless v == 'nil'

        # Verify that the Participant and Subgroup belong to this activity
        # Edit-capability is enforced by before_filter.
        if !p || p.activity != @activity || (!sg && v != 'nil') || (sg && sg.activity != @activity)
          flash_message(:danger, I18n.t(:somethingbroke))
          redirect_to group_activity_edit_subgroups_path(@group, @activity)
          raise ActiveRecord::Rollback
        end

        if v != 'nil'
          p.subgroup = sg
        else
          p.subgroup = nil
        end

        p.save
      end
    end

    flash_message(:success, I18n.t('activities.subgroups.edited'))
    redirect_to edit_group_activity_path(@group, @activity, anchor: 'subgroups')
  end

  # POST /activities/1/immediate_subgroups
  def immediate_subgroups
    if params[:overwrite]
      @activity.clear_subgroups!
    end

    @activity.assign_subgroups!

    if params[:overwrite]
      flash_message(:success, I18n.t('activities.subgroups.redistributed'))
    else
      flash_message(:success, I18n.t('activities.subgroups.remaining_distributed'))
    end

    redirect_to edit_group_activity_path(@group, @activity)
  end

  # POST /activities/1/clear_subgroups
  def clear_subgroups
    @activity.clear_subgroups!

    flash_message(:success, I18n.t('activities.subgroups.cleared'))
    redirect_to edit_group_activity_path(@group, @activity)
  end

  # Shared lookups for rendering the edit-view
  def set_edit_parameters!
    @non_organizers = @activity.participants.where(is_organizer: [false, nil])
    @organizers = @activity.organizers

    @non_organizers_options = @non_organizers.map{|p| [p.person.full_name, p.id] }
    @organizers_options     =     @organizers.map{|p| [p.person.full_name, p.id] }

    @non_organizers_options.sort!
    @organizers_options.sort!

    @subgroup = Subgroup.new if !@subgroup
    @subgroups = @activity.subgroups.order(is_assignable: :desc, name: :asc)
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

    redirect_to edit_group_activity_path(@group, @activity, anchor: 'organizers-add')
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
        set_edit_parameters!
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

  # POST /activities/1/subgroups
  def create_subgroup
    @subgroup = Subgroup.new(subgroup_params)
    @subgroup.activity = @activity

    if @subgroup.save
      flash_message :success, I18n.t('activities.subgroups.created')
      redirect_to edit_group_activity_path(@group, @activity, anchor: 'subgroups-add')
    else
      flash_message :danger, I18n.t('activities.subgroups.create_failed')
      set_edit_parameters!
      render :edit
    end
  end

  # PATCH /activities/1/subgroups/:subgroup_id
  def update_subgroup
    if @subgroup.update(subgroup_params)
      flash_message :success, I18n.t('activities.subgroups.updated')
      redirect_to edit_group_activity_path(@group, @activity, anchor: 'subgroups')
    else
      flash_message :danger, I18n.t('activities.subgroups.update_failed')
      set_edit_parameters!
      render :edit
    end
  end

  # DELETE /activities/1/subgroups/:subgroup_id
  def destroy_subgroup
    @subgroup.destroy
    flash_message :success, I18n.t('activities.subgroups.destroyed')
    redirect_to edit_group_activity_path(@group, @activity, anchor: 'subgroups')
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

    def set_subgroup
      @subgroup = Subgroup.find(params[:subgroup_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def activity_params
      params.require(:activity).permit(:name, :description, :location, :start, :end, :deadline, :reminder_at, :subgroup_division_enabled, :no_response_action)
    end

    def subgroup_params
      params.require(:subgroup).permit(:name, :is_assignable)
    end
end
