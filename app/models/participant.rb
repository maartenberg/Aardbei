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

  validates :person_id,
    uniqueness: {
      scope: :activity_id,
      message: I18n.t('activities.errors.already_in')
    }

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
end
