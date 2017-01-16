# A Member represents the many-to-many relation of Groups to People. At most
# one member may exist for each Person-Group combination.
class Member < ApplicationRecord
  # @!attribute is_leader
  #   @return [Boolean]
  #     whether the person is a leader in the group.

  belongs_to :person
  belongs_to :group

  before_destroy :delete_future_participants!

  validates :person_id,
    uniqueness: {
      scope: :group_id,
      message: "is already a member of this group"
    }

  # Delete all Participants of this Member for Activities in the future.
  # Intended to be called before the member is deleted.
  def delete_future_participants!
    activities = self.group.activities
      .where('start > ?', DateTime.now)

    participants = Participant.where(
      person_id: self.person.id,
      activity: activities
    )

    participants.each do |p|
      p.destroy!
    end
  end
end
