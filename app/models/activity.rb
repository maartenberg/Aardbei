class Activity < ApplicationRecord
  belongs_to :group

  has_many :participants
  has_many :people, through: :participants

  validates :public_name, presence: true
  validates :start, presence: true
  validate  :deadline_before_start

  def organizers
    self.organizers.includes(:person).where(is_organizer: true)
  end

  def is_organizer(person)
    Participant.exists?(person_id: person.id, activity_id: self.id, is_organizer: true)
  end

  private
  def deadline_before_start
    if self.deadline && self.deadline > self.start
      errors.add(:deadline, 'must be before start')
    end
  end
end
