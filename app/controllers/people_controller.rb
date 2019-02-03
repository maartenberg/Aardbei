class PeopleController < ApplicationController
  before_action :set_person, only: [:show, :edit, :update, :destroy]
  before_action :set_person_from_token, only: [:calendar]
  before_action :require_login!, except: [:calendar]
  before_action :require_admin!, except: [:calendar, :show]

  # GET /people
  # GET /people.json
  def index
    @people = Person.all
  end

  # GET /people/1
  # GET /people/1.json
  def show
    require_admin! if @person != current_person
  end

  # GET /people/new
  def new
    @person = Person.new
  end

  # GET /people/1/edit
  def edit; end

  # POST /people
  # POST /people.json
  def create
    @person = Person.new(person_params)

    respond_to do |format|
      if @person.save
        format.html do
          flash_message(:success, I18n.t('person.created'))
          redirect_to @person
        end
        format.json { render :show, status: :created, location: @person }
      else
        format.html { render :new }
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  def mass_new; end

  def mass_create
    require 'csv'
    uploaded_io = params[:spreadsheet]
    result = Person.from_csv(uploaded_io.read)
    flash_message(:success, "#{result.count} people created")
    redirect_to :people
  end

  # PATCH/PUT /people/1
  # PATCH/PUT /people/1.json
  def update
    respond_to do |format|
      if @person.update(person_params)
        format.html do
          flash_message(:success, I18n.t('person.updated'))
          redirect_to @person
        end

        format.json { render :show, status: :ok, location: @person }
      else
        format.html { render :edit }
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /people/1
  # DELETE /people/1.json
  def destroy
    @person.destroy
    respond_to do |format|
      format.html do
        flash_message(:success, I18n.t('person.destroyed'))
        redirect_to people_url
      end

      format.json { head :no_content }
    end
  end

  # GET /c/:calendar_token
  def calendar
    response.content_type = 'text/calendar'

    cal = @person.calendar_feed

    render plain: cal.to_ical
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_person
    @person = Person.find(params[:id])
  end

  # Set person from calendar token
  def set_person_from_token
    @person = Person.find_by(calendar_token: params[:calendar_token])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def person_params
    params.require(:person).permit(:first_name, :infix, :last_name, :email, :is_admin)
  end
end
