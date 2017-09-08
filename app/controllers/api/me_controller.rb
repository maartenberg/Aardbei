class Api::MeController < ApiController
  def index
    @person = current_person
    render 'api/people/show'
  end

  def groups
    @groups = current_person.groups
    render 'api/groups/index'
  end
end
