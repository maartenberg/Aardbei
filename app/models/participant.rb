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
      message: "person already participates in this activity"
    }
end
