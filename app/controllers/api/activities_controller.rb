# Provides read-only access to Activities.
module Api
  class ActivitiesController < ApiController
    has_no_activity = [:index]

    # Session-based authentication/authorization
    before_action :set_activity,        except: has_no_activity
    before_action :require_membership!, except: has_no_activity
    before_action :api_require_admin!,  only: has_no_activity
    skip_before_action :api_require_authentication!, :set_activity, :require_membership!, if: 'request.authorization'

    # Group API-key-based authentication/authorization
    before_action :api_auth_group_token,    if: 'request.authorization'
    before_action :set_activity_with_group, if: 'request.authorization'

    # GET /api/activities
    def index
      @activities = Activity.all
    end

    # GET /api/activities/1
    def show; end

    # GET /api/activities/1/response_summary
    def response_summary
      as = @activity
           .participants
           .joins(:person)
           .order('people.first_name ASC')

      present = as.where(attending: true)

      unknown = as.where(attending: nil)

      absent = as.where(attending: false)

      presentnames = present.map { |p| p.person.first_name }

      unknownnames = unknown.map { |p| p.person.first_name }

      absentnames = absent.map { |p| p.person.first_name }

      present_mess = if presentnames.positive?
                       I18n.t('activities.participant.these_present', count: present.count, names: presentnames.join(', '))
                     else
                       I18n.t('activities.participant.none_present')
                     end

      unknown_mess = if unknownnames.positive?
                       I18n.t('activities.participant.these_unknown', count: unknown.count, names: unknownnames.join(', '))
                     else
                       I18n.t('activities.participant.none_unknown')
                     end

      absent_mess = if absentnames.positive?
                      I18n.t('activities.participant.these_absent', count: absent.count, names: absentnames.join(', '))
                    else
                      I18n.t('activities.participant.none_absent')
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

    def presence
      participant = Participant.find_by(
        person_id: params[:person_id],
        activity: @activity
      )

      participant.update!(params.permit(:attending))
      head :no_content
    end

    private

    # Set activity from the :id-parameter
    def set_activity
      @activity = Activity.find(params[:id])
      @group = @activity.group
    end

    # Set activity from the :id-parameter, and assert that it belongs to the set @group.
    def set_activity_with_group
      @activity = Activity.find_by id: params[:id]
      unless @activity
        head :not_found
        return
      end

      head :unauthorized unless @activity.group == @group
    end
  end
end
