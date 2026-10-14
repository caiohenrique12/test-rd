module PaymentLinks
  class Creator < ApplicationService
    def initialize(account:, description:, amount_cents:, currency:)
      @account = account
      @description = description
      @amount_cents = amount_cents
      @currency = currency
    end

    def call
      url_token = SecureRandom.hex(16)

      account.payment_links.create!(
        public_id: "pl_#{url_token}",
        url_token:,
        status: "active",
        description:,
        amount_cents:,
        currency:
      )
    end

    private

    attr_reader :account, :description, :amount_cents, :currency
  end
end
