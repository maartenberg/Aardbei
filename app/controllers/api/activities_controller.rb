class Api::ActivitiesController < ApiController
  before_action :set_activity, only: [:show, :response_summary]
  before_action :require_membership!, only: [:show, :reponse_summary]
  before_action :api_require_admin!, only: [:index]

  # GET /api/activities
  # GET /api/activities.json
  def index
    @activities = Activity.all
  end

  # GET /api/activities/1
  # GET /api/activities/1.json
  def show
  end

  # GET /api/activities/1/response_summary
  # GET /api/activities/1/response_summary.json
  def response_summary
    as = @activity
      .participants
      .joins(:person)
      .order('people.first_name ASC')

    present = as
      .where(attending: true)

    unknown = as
      .where(attending: nil)

    absent = as
      .where(attending: false)

    presentnames = present
      .map{|p| p.person.first_name }

    unknownnames = unknown
      .map{|p| p.person.first_name }

    absentnames = absent
      .map{|p| p.person.first_name }

    if presentnames.count > 0
      present_mess = I18n.t('activities.participant.these_present', count: present.count, names: presentnames.join(', '))
    else
      present_mess = I18n.t('activities.participant.none_present')
    end

    if unknownnames.count > 0
      unknown_mess = I18n.t('activities.participant.these_unknown', count: unknown.count, names: unknownnames.join(', '))
    else
      unknown_mess = I18n.t('activities.participant.none_unknown')
    end

    if absentnames.count > 0
      absent_mess = I18n.t('activities.participant.these_absent', count: absent.count, names: absentnames.join(', '))
    else
      absent_mess = I18n.t('activities.participant.none_absent')
    end

    @summary = {
      present: {
        count: present.count,
        names: presentnames,
        message: present_mess
      },
      unknown: {
        count: unknown.count,
        names: unknownnames,
        message: unknown_mess
      },
      absent: {
        count: absent.count,
        names: absentnames,
        message: absent_mess
      }
    }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_activity
      @activity = Activity.find(params[:id])
      @group = @activity.group
    end
end
