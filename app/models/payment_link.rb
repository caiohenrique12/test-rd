class PaymentLink < ApplicationRecord
  belongs_to :account

  validates :public_id, uniqueness: true
  validates :url_token, uniqueness: true

  def public_url
    "#{Rails.configuration.x.payment_link_base_url}/c/#{url_token}"
  end
end
