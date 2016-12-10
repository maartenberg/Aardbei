class User < ApplicationRecord
  has_secure_password
  belongs_to :person

  validates :person, presence: true
  validates :email, uniqueness: true

  before_validation :email_same_as_person

  private
  def email_same_as_person
    if self.person and self.email != self.person.email
      errors.add(:email, "must be the same as associated person's email")
    end
  end
end
