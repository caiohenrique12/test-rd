class PaymentLink < ApplicationRecord
  belongs_to :account

  validates :public_id, uniqueness: true
  validates :url_token, uniqueness: true
  validate :amount_must_be_a_positive_integer
  validate :currency_must_be_brl
  validate :description_must_be_present

  def public_url
    "#{Rails.configuration.x.payment_link_base_url}/c/#{url_token}"
  end

  private

  def amount_must_be_a_positive_integer
    raw_amount = amount_cents_before_type_cast
    return if raw_amount.is_a?(Integer) && raw_amount.positive?

    errors.add(:base, "O valor deve ser maior que zero")
  end

  def currency_must_be_brl
    return if currency == "BRL"

    errors.add(:base, "A moeda não é suportada")
  end

  def description_must_be_present
    return unless description.to_s.strip.empty?

    errors.add(:base, "A descrição é obrigatória")
  end
end
