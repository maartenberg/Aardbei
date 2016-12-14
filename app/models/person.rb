class Person < ApplicationRecord
  has_one :user
  has_many :members
  has_many :participants
  has_many :groups, through: :members
  has_many :activities, through: :participants

  validates :email, presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true

  validate :birth_date_cannot_be_in_future

  before_validation :not_admin_if_nil
  before_save :update_user_email, if: :email_changed?

  def full_name
    if self.infix
      [self.first_name, self.infix, self.last_name].join(' ')
    else
      [self.first_name, self.last_name].join(' ')
    end
  end

  def reversed_name
    if self.infix
      [self.last_name, self.infix, self.first_name].join(', ')
    else
      [self.last_name, self.first_name].join(', ')
    end
  end

  private
  def birth_date_cannot_be_in_future
    if self.birth_date && self.birth_date > Date.today
      errors.add(:birth_date, "can't be in the future.")
    end
  end

  def not_admin_if_nil
    self.is_admin ||= false
  end

  def update_user_email
    if not self.user.nil?
      self.user.update!(email: self.email)
    end
  end
end
