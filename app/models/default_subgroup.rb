class DefaultSubgroup < ApplicationRecord
  belongs_to :group

  validates :name, presence: true, uniqueness: { scope: :group, case_sensitive: false }
  validates :group, presence: true
end
