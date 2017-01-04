# A Member represents the many-to-many relation of Groups to People. At most
# one member may exist for each Person-Group combination.
class Member < ApplicationRecord
  # @!attribute is_leader
  #   @return [Boolean]
  #     whether the person is a leader in the group.

  belongs_to :person
  belongs_to :group

  validates :person_id,
    uniqueness: {
      scope: :group_id,
      message: "is already a member of this group"
    }
end
