# A Member represents the many-to-many relation of Groups to People. At most
# one member may exist for each Person-Group combination.
class Member < ApplicationRecord
  # @!attribute is_leader
  #   @return [Boolean]
  #     whether the person is a leader in the group.
  #
  # @!attribute display_name
  #   @return [String]
  #     a version of the name of this Member that is short enough to uniquely identify this Member in the Group.
  #     Example: If a group has only one Person with the first name "Steve", the Member's display name will be
  #     just "Steve". If, however, there is both a "Steve Doe" and a "Steve Stevenson", their display names will
  #     be "Steve D." and "Steve S.".
  #
  #     The display name may also be altered by a Group leader, to contain e.g. a nickname.
  #   @see Member.update_display_name!

  belongs_to :person
  belongs_to :group
  has_many :participants, dependent: :destroy
  has_many :activities, through: :participants

  after_create   :create_future_participants!
  after_create   :update_display_name!
  before_destroy :delete_future_participants!
  after_destroy  :check_remaining_display_names!

  validates :person_id,
            uniqueness: {
              scope: :group_id,
              message: I18n.t('groups.member.already_in')
            }
  validates :display_name, uniqueness: { scope: :group_id }

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
        member: self
      )
    end
  end

  # Update this Member's unique enough name, as well as the names of any other Members with the same first name.
  def update_display_name!
    same_first_name = group.members.joins(:person).where('people.first_name' => person.first_name)

    if same_first_name.count < 2
      self.display_name = person.first_name
      save!

      return
    end

    # Second variant
    first_letters = same_first_name.map { |m| m.person.last_name[0] }

    # If everyone has a different first letter of the last name
    if first_letters.to_set.count == same_first_name.count
      same_first_name.each do |m|
        p = m.person
        m.display_name = if p.infix.present?
                               then "#{p.first_name} #{p.infix} #{p.last_name[0]}."
                         else "#{p.first_name} #{p.last_name[0]}."
                         end
      end
      same_first_name.each(&:save!)

      return
    end

    # We give up, display name is now your full name.
    same_first_name.each do |m|
      m.display_name = m.person.full_name
    end
  end

  # Delete all Participants of this Member for Activities in the future.
  # Intended to be called before the member is deleted.
  def delete_future_participants!
    participants = Participant.where(
      member_id: id,
      activity: group.future_activities
    )

    participants.each(&:destroy!)
  end

  # Destroy callback. Check whether there is a Person with the same first_name
  # in the Group that this Member is being deleted from.
  # If so, grab the first one and run update_display_name!.
  def check_remaining_display_names!
    p = group.people.where(first_name: person.first_name)

    return unless p

    Member.find_by(person: p, group: group).update_display_name!
  end
end
