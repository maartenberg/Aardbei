class Token < ApplicationRecord
  # A Token contains some information that can be used as an alternative way to
  # authenticate a user, typically instead of a username/password combination.
  #
  # At least the following types of tokens will exist:
  #  - Account confirmation tokens, sent to the user when their account is
  #    created (to verify their email address)
  #  - Password reset tokens
  #  - API authentication tokens
  #
  # @!attribute token
  #  @return [String]
  #    a unique token, that allows the holder to perform some action.
  #
  # @!attribute expires
  #   @return [DateTime]
  #     when the token will expire (and will no longer be usable). May be nil
  #     for no expiry.
  #
  # @!attribute tokentype
  #   @return [String]
  #     what action the token allows the holder to perform. Use the hash
  #     Token::TYPES instead of comparing directly!
  #
  # @!attribute user
  #   @return [User]
  #     what user the token allows the holder to authenticate as.

  TYPES = {
    password_reset:       'pw_reset',
    account_confirmation: 'confirm',
    api_authentication:   'api'
  }

  validates :token, uniqueness: true, presence: true
  validates :user, presence: true

  belongs_to :user

  before_validation :generate_token, if: "self.token.blank?"
  before_validation :generate_expiry, on: :create

  private

  def generate_token
    candidate = nil
    loop do
      candidate = SecureRandom::urlsafe_base64 32
      break candidate unless Token.exists?(token: candidate)
    end
    self.token = candidate
  end

  # Defines the default expiry for the expiring tokens.
  def generate_expiry
    case self.tokentype
    when TYPES[:password_reset]
      self.expires = 1.days.since
    when TYPES[:account_confirmation]
      self.expires = 7.days.since
    end
  end
end
