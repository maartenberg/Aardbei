# A User contains the login information for a single Person, and allows the
# user to log in by creating Sessions.
class User < ApplicationRecord
  # @!attribute email
  #   @return [String]
  #     the user's email address. Should be the same as the associated Person's
  #     email address.
  #
  # @!attribute confirmed
  #   @return [Boolean]
  #     whether or not this account has been activated yet.

  has_secure_password
  belongs_to :person

  validates :person, presence: true
  validates :email, uniqueness: true

  before_validation :email_same_as_person

  private
  # Assert that the user's email address is the same as the email address of
  # the associated Person.
  def email_same_as_person
    if self.person and self.email != self.person.email
      errors.add(:email, I18n.t('authentication.user_person_mail_mismatch'))
    end
  end
end
