# A Member represents the many-to-many relation of Groups to People. At most
# one member may exist for each Person-Group combination.
class Member < ApplicationRecord
  # @!attribute is_leader
  #   @return [Boolean]
  #     whether the person is a leader in the group.

  belongs_to :person
  belongs_to :group

  after_create   :create_future_participants!
  before_destroy :delete_future_participants!

  validates :person_id,
            uniqueness: {
              scope: :group_id,
              message: I18n.t('groups.member.already_in')
            }

  # Create Participants for this Member for all the group's future activities, where the member isn't enrolled yet.
  # Intended to be called after the member is added to the group.
  def create_future_participants!
    activities = group.future_activities

    unless person.activities.empty?
      activities = activities.where(
        'activities.id NOT IN (?)', person.activities.ids
      )
    end

    activities.each do |a|
      Participant.create!(
        activity: a,
        person: person
      )
    end
  end

  # Delete all Participants of this Member for Activities in the future.
  # Intended to be called before the member is deleted.
  def delete_future_participants!
    participants = Participant.where(
      person_id: person.id,
      activity: group.future_activities
    )

    participants.each(&:destroy!)
  end
end
