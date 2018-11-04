# A Group contains Members, which can organize and participate in Activities.
# Some of the Members may be group leaders, with the ability to see all
# information and add or remove members from the group.
class Group < ApplicationRecord
  # @!attribute name
  #   @return [String]
  #     the name of the group. Must be unique across all groups.

  has_secure_token :api_token
  has_many :members,
    dependent: :destroy
  has_many :people, through: :members

  has_many :activities,
    dependent: :destroy

  has_many :default_subgroups,
    dependent: :destroy

  validates :name,
    presence: true,
    uniqueness: {
      case_sensitive: false
    }

  # @return [Array<Member>] the members in the group who are also group leaders.
  def leaders
    self.members.includes(:person).where(is_leader: true)
  end

  # @return [Array<Activity>] the activities that haven't started yet.
  def future_activities
    self.activities.where('start > ?', DateTime.now)
  end

  # @return [Array<Activity>]
  #   all Activities that have started, and not yet ended.
  def current_activities(reference = Time.zone.now)
    activities
      .where('start < ?', reference)
      .where('end > ?', reference)
  end

  # @return [Array<Activity>]
  #   at most 3 activities that ended recently.
  def previous_activities(reference = Time.zone.now)
    activities
      .where('end < ?', reference)
      .order(end: :desc)
      .limit(3)
  end

  # @return [Array<Activity>]
  #   all Activities starting within the next 48 hours.
  def upcoming_activities(reference = Time.zone.now)
    activities
      .where('start > ?', reference)
      .where('start < ?', reference.days_since(2))
      .order(start: :asc)
  end

  # @return [Boolean]
  #   whether the passed person is a member of the group.
  def is_member?(person)
    Member.exists?(
      person: person,
      group: self
    ) || person.is_admin?
  end

  # @return [Boolean]
  #   whether the passed person is a group leader.
  def is_leader?(person)
    Member.exists?(
      person: person,
      group: self,
      is_leader: true
    ) || person.is_admin?
  end
end
