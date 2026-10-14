class Account < ApplicationRecord
  has_many :access_tokens, dependent: :destroy
  has_many :payment_links, dependent: :destroy
end
