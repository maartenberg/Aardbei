class MembersController < ApplicationController
  include GroupsHelper
  before_action :set_group
  before_action :set_member, only: [:show, :edit, :update, :destroy]
  before_action :require_leader!

  # GET /members
  # GET /members.json
  def index
    @members = Member.all
  end

  # GET /members/1
  # GET /members/1.json
  def show
  end

  # GET /members/new
  def new
    @member = Member.new
    @possible_members = Person.where.not(id: @group.person_ids)
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
        format.html { redirect_to group_member_url(@group, @member), notice: 'Member was successfully created.' }
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
        format.html { redirect_to group_member_url(@group, @member), notice: 'Member was successfully updated.' }
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
      format.html { redirect_to group_members_url(@group), notice: 'Member was successfully destroyed.' }
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
end
