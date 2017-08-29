# A person represents a human being. A Person may be a Member in one or more
# Groups, and be a Participant in any number of events of those Groups.
# A Person may access the system by creating a User, and may have at most one
# User.
class Person < ApplicationRecord
  # @!attribute first_name
  #   @return [String]
  #     the person's first name. ('Vincent' in 'Vincent van Gogh'.)
  #
  # @!attribute infix
  #   @return [String]
  #     the part of a person's surname that is not taken into account when
  #     sorting by surname. ('van' in 'Vincent van Gogh'.)
  #
  # @!attribute last_name
  #   @return [String]
  #     the person's surname. ('Gogh' in 'Vincent van Gogh'.)
  #
  # @!attribute birth_date
  #   @return [Date]
  #     the person's birth date.
  #
  # @!attribute email
  #   @return [String]
  #     the person's email address.
  #
  # @!attribute is_admin
  #   @return [Boolean]
  #     whether or not the person has administrative rights.

  has_one :user
  has_many :members,
    dependent: :destroy
  has_many :participants,
    dependent: :destroy
  has_many :groups, through: :members
  has_many :activities, through: :participants

  validates :email, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true

  validate :birth_date_cannot_be_in_future

  before_validation :not_admin_if_nil
  before_save :update_user_email, if: :email_changed?

  # The person's full name.
  def full_name
    if self.infix
      [self.first_name, self.infix, self.last_name].join(' ')
    else
      [self.first_name, self.last_name].join(' ')
    end
  end

  # The person's reversed name, to sort by surname.
  def reversed_name
    if self.infix
      [self.last_name, self.infix, self.first_name].join(', ')
    else
      [self.last_name, self.first_name].join(', ')
    end
  end

  # All activities where this person is an organizer.
  def organized_activities
    self.participants.includes(:activity).where(is_organizer: true)
  end

  private
  # Assert that the person's birth date, if any, lies in the past.
  def birth_date_cannot_be_in_future
    if self.birth_date && self.birth_date > Date.today
      errors.add(:birth_date, I18n.t('person.errors.cannot_future'))
    end
  end

  # Explicitly force nil to false in the admin field.
  def not_admin_if_nil
    self.is_admin ||= false
  end

  # Ensure the person's user email is updated at the same time as the person's
  # email.
  def update_user_email
    if not self.user.nil?
      self.user.update!(email: self.email)
    end
  end
end
