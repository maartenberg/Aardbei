class GroupsController < ApplicationController
  include GroupsHelper
  before_action :set_group, only: [:show, :edit, :update, :destroy]
  before_action :require_admin!, only: [:index, :process_mass_add_members, :mass_add_members]
  before_action :require_membership!, only: [:show]
  before_action :require_leader!, only: [:edit, :update, :destroy]

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
    @organized_activities = current_person.organized_activities.
      joins(:activity).where(
        'activities.group_id': @group.id
    )
    if @organized_activities.count > 0
      @groupmenu = 'col-md-6'
    else
      @groupmenu = 'col-md-12'
    end

    @upcoming = @group.activities
      .where('start > ?', Date.today)
      .order('start ASC')
    @upcoming_ps = Participant
      .where(person: current_person)
      .where(activity: @upcoming)
      .map{ |p| [p.activity_id, p]}
      .to_h
  end

  # GET /groups/new
  def new
    @group = Group.new
  end

  # GET /groups/1/edit
  def edit
  end

  # POST /groups
  # POST /groups.json
  def create
    @group = Group.new(group_params)

    respond_to do |format|
      if @group.save
        format.html {
          redirect_to @group
          flash_message(:info, I18n.t('groups.created'))
        }
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
        format.html {
          redirect_to @group
          flash_message(:info, I18n.t('groups.updated'))
        }
        format.json { render :show, status: :ok, location: @group }
      else
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
      format.html {
        redirect_to groups_url
        flash_message(:info, I18n.t('groups.destroyed'))
      }
      format.json { head :no_content }
    end
  end

  def mass_add_members
    @group = Group.find(params[:group_id])
  end

  def process_mass_add_members
    @group = Group.find(params[:group_id])
    require 'csv'
    uploaded_io = params[:spreadsheet]
    result = Person.from_csv(uploaded_io.read)

    result.each do |p|
      m = Member.find_by(person: p, group: @group)
      if not m
        m = Member.new(person: p, group: @group)
        m.save!
      end
    end
    flash_message(:success, "#{result.count} people added to group")
    redirect_to group_members_path(@group)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group
      @group = Group.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def group_params
      params.require(:group).permit(:name)
    end
end
