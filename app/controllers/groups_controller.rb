class GroupsController < ApplicationController
  include GroupsHelper
  before_action :require_login!

  before_action :set_group, only: [:show, :edit, :update, :destroy, :create_default_subgroup, :update_default_subgroup, :destroy_default_subgroup, :mass_add_members, :process_mass_add_members]
  before_action :set_default_subgroup, only: [:update_default_subgroup, :destroy_default_subgroup]
  before_action :require_admin!, only: [:index]
  before_action :require_membership!, only: [:show]
  before_action :require_leader!, only: [:edit, :update, :destroy, :create_default_subgroup, :update_default_subgroup, :destroy_default_subgroup, :process_mass_add_members, :mass_add_members]

  # GET /groups
  # GET /groups.json
  def index
    @groups = Group.all
  end

  def user_groups
    @groups = current_person.groups
  end

  # GET /groups/1
  # GET /groups/1.json
  def show
    @organized_activities = current_person
                            .organized_activities
                            .joins(:activity)
                            .where('activities.group_id': @group.id)
                            .where('start > ?', Time.zone.today)

    @groupmenu = if @organized_activities.any?
                   'col-md-6'
                 else
                   'col-md-12'
                 end

    @upcoming = @group.activities
                      .where('start > ?', Time.zone.today)
                      .order('start ASC')
    @upcoming_ps = Participant.includes(:person)
                              .where('people.id' => current_person.id)
                              .where(activity: @upcoming)
                              .map { |p| [p.activity_id, p] }
                              .to_h
  end

  # GET /groups/new
  def new
    @group = Group.new
  end

  # GET /groups/1/edit
  def edit
    @defaultsubgroup = DefaultSubgroup.new
  end

  # POST /groups
  # POST /groups.json
  def create
    @group = Group.new(group_params)

    respond_to do |format|
      if @group.save
        format.html do
          redirect_to @group
          flash_message(:info, I18n.t('groups.created'))
        end
        format.json { render :show, status: :created, location: @group }
      else
        format.html { render :new }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /groups/1
  # PATCH/PUT /groups/1.json
  def update
    respond_to do |format|
      if @group.update(group_params)
        format.html do
          redirect_to @group
          flash_message(:info, I18n.t('groups.updated'))
        end
        format.json { render :show, status: :ok, location: @group }
      else
        @defaultsubgroup = DefaultSubgroup.new
        format.html { render :edit }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /groups/1
  # DELETE /groups/1.json
  def destroy
    @group.destroy
    respond_to do |format|
      format.html do
        redirect_to groups_url
        flash_message(:info, I18n.t('groups.destroyed'))
      end
      format.json { head :no_content }
    end
  end

  def mass_add_members; end

  def process_mass_add_members
    require 'csv'
    uploaded_io = params[:spreadsheet]
    result = Person.from_csv(uploaded_io.read)

    result.each do |p|
      m = Member.find_by(person: p, group: @group)
      unless m
        m = Member.new(person: p, group: @group)
        m.save!
      end
    end
    flash_message(:success, I18n.t('groups.mass_add_success', count: result.count))
    redirect_to group_members_path(@group)
  end

  # POST /groups/:id/default_subgroups
  def create_default_subgroup
    @defaultsubgroup = DefaultSubgroup.new(default_subgroup_params)
    @defaultsubgroup.group = @group

    if @defaultsubgroup.save
      flash_message(:success, I18n.t('defaultsubgroups.created'))
      redirect_to edit_group_path(@group)
    else
      flash_message(:danger, I18n.t('defaultsubgroups.create_failed'))
      render :edit
    end
  end

  # PATCH /groups/:id/default_subgroups/:default_subgroup_id
  def update_default_subgroup
    if @defaultsubgroup.update(default_subgroup_params)
      flash_message(:success, I18n.t('defaultsubgroups.updated'))
      redirect_to edit_group_path(@group)
    else
      flash_message(:danger, I18n.t('defaultsubgroups.update_failed'))
      render :edit
    end
  end

  # DELETE /groups/:id/default_subgroups/:default_subgroup_id
  def destroy_default_subgroup
    @defaultsubgroup.destroy
    flash_message(:info, I18n.t('defaultsubgroups.destroyed'))
    redirect_to edit_group_path(@group)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_group
    @group = Group.find(params[:group_id] || params[:id])
  end

  # Retrieve DefaultSubgroup to update or delete
  def set_default_subgroup
    @defaultsubgroup = DefaultSubgroup.find(params[:default_subgroup_id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def group_params
    params.require(:group).permit(:name)
  end

  def default_subgroup_params
    params.require(:default_subgroup).permit(:name, :is_assignable)
  end
end
