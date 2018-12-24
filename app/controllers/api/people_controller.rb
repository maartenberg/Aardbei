class Api::PeopleController < ApiController
  before_action :set_person, only: [:show]
  before_action :api_require_admin! # Normal people should use /me

  # GET /api/people
  # GET /api/people.json
  def index
    @people = Person.all
  end

  # GET /api/people/1
  # GET /api/people/1.json
  def show
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_person
    @person = Person.find(params[:id])
  end
end
