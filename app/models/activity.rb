class Activity < ApplicationRecord
  belongs_to :group

  has_many :participants
  has_many :people, through: :participants
end
