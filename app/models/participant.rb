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

  belongs_to :person
  belongs_to :activity
  belongs_to :subgroup, optional: true

  after_validation :clear_subgroup, if: 'self.attending != true'

  validates :person_id,
    uniqueness: {
      scope: :activity_id,
      message: I18n.t('activities.errors.already_in')
    }

  HUMAN_ATTENDING = {
    true => I18n.t('activities.state.present'),
    false => I18n.t('activities.state.absent'),
    nil => I18n.t('activities.state.unknown')
  }

  # @return [String]
  #   the name for the Participant's current state in the current locale.
  def human_attending
    HUMAN_ATTENDING[self.attending]
  end

  ICAL_ATTENDING = {
    true => 'ATTENDING',
    false => 'CANCELLED',
    nil => 'TENTATIVE'
  }

  # @return [String]
  #   the ICal attending response.
  def ical_attending
    ICAL_ATTENDING[self.attending]
  end

  # TODO: Move to a more appropriate place
  # @return [String]
  #   the class for a row containing this activity.
  def row_class
    if self.attending
      "success"
    elsif self.attending == false
      "danger"
    else
      "warning"
    end
  end

  def may_change?(person)
    self.activity.may_change?(person) ||
    self.person == person
  end

  # Set attending to true if nil, and notify the Person via email.
  def send_reminder
    return unless self.attending.nil?

    self.attending = self.activity.no_response_action
    notes = self.notes || ""
    notes << '[auto]'
    self.notes = notes
    self.save

    return unless self.person.send_attendance_reminder
    ParticipantMailer.attendance_reminder(self.person, self.activity).deliver_later
  end

  # Send subgroup information email if person is attending.
  def send_subgroup_notification
    return unless self.attending && self.subgroup

    ParticipantMailer.subgroup_notification(self.person, self.activity, self).deliver_later
  end

  # Clear subgroup if person is set to 'not attending'.
  def clear_subgroup
    self.subgroup = nil
  end

end
