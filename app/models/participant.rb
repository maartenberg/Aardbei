# A Participant represents the many-to-many relation between People and
# Activities, and contains the information on whether or not the person plans
# to be present at the activity.
class Participant < ApplicationRecord
  # @!attribute is_organizer
  #   @return [Boolean]
  #     whether the person is an organizer for this event.
  #
  # @!attribute attending
  #   @return [Boolean]
  #     whether or not the person plans to attend the activity.
  #
  # @!attribute notes
  #   @return [String]
  #     a short text indicating any irregularities, such as arriving later or
  #     leaving earlier.

  belongs_to :member, autosave: false
  has_one :person, through: :member
  belongs_to :activity
  belongs_to :subgroup, optional: true

  after_validation :clear_subgroup, if: 'self.attending != true'

  validates :member_id,
            uniqueness: {
              scope: :activity_id,
              message: I18n.t('activities.errors.already_in')
            }

  HUMAN_ATTENDING = {
    true => I18n.t('activities.state.present'),
    false => I18n.t('activities.state.absent'),
    nil => I18n.t('activities.state.unknown')
  }.freeze

  # @return [String]
  #   the name for the Participant's current state in the current locale.
  def human_attending
    HUMAN_ATTENDING[attending]
  end

  ICAL_ATTENDING = {
    true => 'ATTENDING',
    false => 'CANCELLED',
    nil => 'TENTATIVE'
  }.freeze

  # @return [String]
  #   the ICal attending response.
  def ical_attending
    ICAL_ATTENDING[attending]
  end

  # TODO: Move to a more appropriate place
  # @return [String]
  #   the class for a row containing this activity.
  def row_class
    if attending
      "success"
    elsif attending == false
      "danger"
    else
      "warning"
    end
  end

  def may_change?(person)
    activity.may_change?(person) ||
      self.person == person
  end

  # Set attending to true if nil, and notify the Person via email.
  def send_reminder
    return unless attending.nil?

    self.attending = activity.no_response_action
    notes = self.notes || ""
    notes << '[auto]'
    self.notes = notes
    save

    return unless person.send_attendance_reminder

    ParticipantMailer.attendance_reminder(person, activity).deliver_later
  end

  # Send subgroup information email if person is attending.
  def send_subgroup_notification
    return unless attending && subgroup

    ParticipantMailer.subgroup_notification(person, activity, self).deliver_later
  end

  # Clear subgroup if person is set to 'not attending'.
  def clear_subgroup
    self.subgroup = nil
  end

  # Fallback handler after display_name changes
  def person_id
    Raven.capture_message("Unconverted call to person_id")
    person.id
  end
end
