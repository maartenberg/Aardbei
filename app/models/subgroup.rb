class Subgroup < ApplicationRecord
  belongs_to :activity
  has_many :participants

  validates :name, presence: true, uniqueness: { scope: :activity, case_sensitive: false }
  validates :activity, presence: true
end
