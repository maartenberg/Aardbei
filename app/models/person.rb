class Person < ApplicationRecord
  has_one :user

  validates :email, presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :is_admin, presence: true

  validate :birth_date_cannot_be_in_future

  before_validation :not_admin_if_nil
  before_save :update_user_email, if: :email_changed?

  private
  def birth_date_cannot_be_in_future
    if self.birth_date > Date.today
      errors.add(:birth_date, "can't be in the future.")
    end
  end

  def not_admin_if_nil
    self.is_admin ||= false
  end

  def update_user_email
    self.user.update!(email: self.email)
  end
end
