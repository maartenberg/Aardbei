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

  # Set all sessions associated with this User to inactive, for instance after
  # a password change, or when the user selects this options in the Settings.
  def logout_all_sessions!
    Session.where(user: self)
           .update_all(active: false) # rubocop:disable Rails/SkipsModelValidations
  end

  private

  # Assert that the user's email address is the same as the email address of
  # the associated Person.
  def email_same_as_person
    errors.add(:email, I18n.t('authentication.user_person_mail_mismatch')) if person && (email != person.email)
  end
end
