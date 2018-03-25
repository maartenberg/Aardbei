class Subgroup < ApplicationRecord
  belongs_to :activity
  has_many :participants

  validates :name, presence: true, uniqueness: { scope: :activity, case_sensitive: false }
  validates :activity, presence: true

  def participant_names
    self
      .participants
      .joins(:person)
      .map { |p| p.person.full_name }
      .sort
  end
end
