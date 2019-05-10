class MembersController < ApplicationController
  include GroupsHelper
  before_action :set_group
  before_action :set_member, only: [:show, :edit, :update, :destroy, :promote, :demote]
  before_action :require_leader!, except: [:index]

  # GET /members
  # GET /members.json
  def index
    @admin = @group.leader?(current_person)
    @members = @group.members
                     .joins(:person)
                     .order('members.is_leader DESC, people.first_name ASC')
  end

  # GET /members/1
  # GET /members/1.json
  def show
    @participants = @member
                    .participants
                    .joins(:activity)
                    .paginate(page: params[:page], per_page: 25)

    if params[:past]
      @participants = @participants
                      .where('activities.end <= ? OR (activities.end IS NULL AND activities.start <= ?)', Time.zone.now, Time.zone.now)
                      .order('activities.start DESC')
    else
      @participants = @participants
                      .where('activities.end >= ? OR (activities.end IS NULL AND activities.start >= ?)', Time.zone.now, Time.zone.now)
                      .order('activities.start ASC')
    end
  end

  # GET /members/new
  def new
    @member = Member.new
    @possible_members = Person.where.not(id: @group.person_ids)
  end

  def invite
    @person = Person.new
  end

  def promote
    @member.update!(is_leader: true)
    flash_message(:success, I18n.t('groups.leader_added', name: @member.person.full_name))
    redirect_to group_members_path(@group)
  end

  def demote
    @member.update!(is_leader: false)
    flash_message(:success, I18n.t('groups.leader_removed', name: @member.person.full_name))
    redirect_to group_members_path(@group)
  end

  def process_invite
    @person = Person.find_by(email: params[:person][:email])
    new_rec = false
    unless @person
      @person = Person.new(invite_params)
      new_rec = true

      unless @person.save
        respond_to do |format|
          format.html { render 'invite' }
          format.json { render json: @person.errors, status: :unprocessable_entity }
        end
        return
      end
    end

    @member = Member.new(person: @person, group: @group, is_leader: false)
    @member.save!

    respond_to do |format|
      format.html do
        invited = ""
        invited = "invited to Aardbei and " if new_rec

        flash_message(
          :success,
          "#{@person.full_name} #{invited}added to group."
        )
        redirect_to group_members_path(@group)
      end

      format.json { render :show, status: :created, location: @person }
    end
  end

  # GET /members/1/edit
  def edit
    @possible_members = Person.where.not(id: @group.person_ids)
  end

  # POST /members
  # POST /members.json
  def create
    @member = Member.new(member_params)
    @member.group = @group

    respond_to do |format|
      if @member.save
        format.html do
          redirect_to group_member_url(@group, @member)
          flash_message(:info, I18n.t('groups.member_added', name: @member.person.full_name))
        end
        format.json { render :show, status: :created, location: @member }
      else
        @possible_members = Person.where.not(id: @group.person_ids)
        format.html { render :new }
        format.json { render json: @member.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /members/1
  # PATCH/PUT /members/1.json
  def update
    respond_to do |format|
      if @member.update(member_params)
        format.html do
          redirect_to group_member_url(@group, @member)
          flash_message(:info, I18n.t('groups.member_updated'))
        end
        format.json { render :show, status: :ok, location: @member }
      else
        @possible_members = Person.where.not(id: @group.person_ids)
        format.html { render :edit }
        format.json { render json: @member.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /members/1
  # DELETE /members/1.json
  def destroy
    @member.destroy
    respond_to do |format|
      format.html do
        redirect_to group_members_url(@group)
        flash_message(:info, I18n.t('groups.member_removed', name: @member.person.full_name))
      end
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_member
    @member = Member.find(params[:id])
  end

  def set_group
    @group = Group.find(params[:group_id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def member_params
    params.require(:member).permit(:person_id, :is_leader)
  end

  # Never trust parameters from the scary internet, only allow the white list
  # through.  Note: differs from the ones in PeopleController because
  # creating admins is not allowed.
  def invite_params
    params.require(:person).permit(:first_name, :infix, :last_name, :email)
  end
end
