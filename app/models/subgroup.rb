class Subgroup < ApplicationRecord
  belongs_to :activity

  validates :name, presence: true, uniqueness: { scope: :activity, case_sensitive: false }
  validates :activity, presence: true
end
