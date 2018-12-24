# A Session contains the information about a logged-in user.
class Session < ApplicationRecord
  # @!attribute ip
  #   @return [String]
  #     the IP address of the client that started the session.
  #
  # @!attribute expires
  #   @return [TimeWithZone]
  #     when the user must be logged out.
  #
  # @!attribute remember_digest
  #   @return [String]
  #     a salted hash of the user's remember token. This token may be used if
  #     the user continues a session by using the 'remember me' option.
  #
  # @!attribute active
  #   @return [Boolean]
  #     whether or not the session may still be used to authenticate.
  #     Inactive sessions may be retained for logging, but must not allow a user
  #     to continue using the system.

  belongs_to :user

  # @return [String] a new random token.
  def self.new_token
    SecureRandom.urlsafe_base64
  end

  # @return [String] a BCrypt digest of the given string.
  def self.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end
end
