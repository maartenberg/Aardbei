class Group < ApplicationRecord
  has_many :members
  has_many :people, through: :members

  has_many :activities

  def leaders
    self.members.where(is_leader: true)
  end
end
