class PaymentLink < ApplicationRecord
  DESCRIPTION_MAX_LENGTH = 140

  belongs_to :account

  normalizes :description, with: ->(description) { description.strip }

  validates :public_id, uniqueness: true
  validates :url_token, uniqueness: true
  validate :amount_must_be_a_positive_integer
  validate :currency_must_be_brl
  validate :description_must_be_present
  validate :description_must_fit_max_length

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

  def description_must_fit_max_length
    return if description.to_s.strip.length <= DESCRIPTION_MAX_LENGTH

    errors.add(:base, "A descrição deve ter no máximo #{DESCRIPTION_MAX_LENGTH} caracteres")
  end
end
