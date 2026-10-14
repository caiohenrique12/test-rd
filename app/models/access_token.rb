class AccessToken < ApplicationRecord
  belongs_to :account

  validates :token_digest, presence: true, uniqueness: true
end
