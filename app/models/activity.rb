# An Activity represents a single continuous event that the members of a group may attend.
# An Activity belongs to a group, and has many participants.
class Activity < ApplicationRecord
  # @!attribute public_name
  #   @return [String]
  #     the name that users will see if there is no {#secret_name}, or if
  #     {#show_hidden} is `false`.
  #
  # @!attribute secret_name
  #   @return [String]
  #     a name that is (be default) only visible to organizers and group
  #     leaders.  Can be shown or hidden to normal participants using
  #     {#show_hidden}.
  #
  # @!attribute description
  #   @return [String]
  #     a short text describing the activity. This text is always visible to
  #     all users.
  #
  # @!attribute location
  #   @return [String]
  #     a short text describing where the activity will take place. Always
  #     visible to all participants.
  #
  # @!attribute show_hidden
  #   @return [Boolean]
  #     Whether or not the 'secret' attributes can be viewed by the people who
  #     aren't organizers or group leaders. Currently, only {#secret_name} is
  #     influenced by this. More attributes may be added in the future, and
  #     will be controlled by this toggle as well.
  #
  # @!attribute start
  #   @return [TimeWithZone]
  #     when the activity starts.
  #
  # @!attribute end
  #   @return [TimeWithZone]
  #     when the activity ends.
  #
  # @!attribute deadline
  #   @return [TimeWithZone]
  #     when the normal participants (everyone who isn't an organizer or group
  #     leader) may not change their own attendance anymore. Disabled if set to
  #     nil.

  belongs_to :group

  has_many :participants,
    dependent: :destroy
  has_many :people, through: :participants

  validates :public_name, presence: true
  validates :start, presence: true
  validate  :deadline_before_start, unless: "self.deadline.blank?"
  validate  :end_after_start,       unless: "self.end.blank?"

  after_create :create_missing_participants!

  # Get all people (not participants) that are organizers. Does not include
  # group leaders, although they may modify the activity as well.
  def organizers
    self.participants.includes(:person).where(is_organizer: true)
  end

  # Determine whether the passed Person participates in the activity.
  def is_participant?(person)
    Participant.exists?(
      activity_id: self.id,
      person_id: person.id
    )
  end

  # Determine whether the passed Person is an organizer for the activity.
  def is_organizer?(person)
    Participant.exists?(
      person_id: person.id,
      activity_id: self.id,
      is_organizer: true
    )
  end

  # Query the database to determine the amount of participants that are present/absent/unknown
  def state_counts
    self.participants.group(:attending).count
  end

  # Determine whether the passed Person may change this activity.
  def may_change?(person)
    person.is_admin ||
    self.is_organizer?(person) ||
    self.group.is_leader?(person)
  end

  # Create Participants for all People that
  #  1. are members of the group
  #  2. do not have Participants (and thus, no way to confirm) yet
  def create_missing_participants!
    people = self.group.people
    if not self.participants.empty?
      people = people.where('people.id NOT IN (?)', self.people.ids)
    end

    people.each do |p|
      Participant.create(
        activity: self,
        person: p,
      )
    end
  end

  private
  # Assert that the deadline for participants to change the deadline, if any,
  # is set before the event starts.
  def deadline_before_start
    if self.deadline > self.start
      errors.add(:deadline, 'must be before start')
    end
  end

  # Assert that the activity's end, if any, occurs after the event's start.
  def end_after_start
    if self.end < self.start
      errors.add(:end, 'must be after start')
    end
  end
end
