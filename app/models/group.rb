# A Group contains Members, which can organize and participate in Activities.
# Some of the Members may be group leaders, with the ability to see all
# information and add or remove members from the group.
class Group < ApplicationRecord
  # @!attribute name
  #   @return [String]
  #     the name of the group. Must be unique across all groups.

  has_many :members
  has_many :people, through: :members

  has_many :activities

  validates :name,
    presence: true,
    uniqueness: {
      case_sensitive: false
    }

  # @return [Array<Member>] the members in the group who are also group leaders.
  def leaders
    self.members.includes(:person).where(is_leader: true)
  end

  # Determine whether the passed person is a group leader.
  def is_leader?(person)
    Member.exists?(
      person: person,
      group: self,
      is_leader: true
    )
  end
end
