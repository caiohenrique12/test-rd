module PaymentLinks
  class Creator < ApplicationService
    Result = Data.define(:payment_link, :error) do
      def success?
        error.nil?
      end

      def as_json(*)
        return { error: } unless success?

        {
          id: payment_link.public_id,
          account_id: payment_link.account_id,
          status: payment_link.status,
          description: payment_link.description,
          amount: payment_link.amount_cents,
          currency: payment_link.currency,
          url: payment_link.public_url
        }
      end
    end

    def initialize(account:, description:, amount_cents:, currency:)
      @account = account
      @description = description
      @amount_cents = amount_cents
      @currency = currency
    end

    def call
      return failure("O valor deve ser maior que zero") unless positive_amount?
      return failure("A descrição é obrigatória") if description.to_s.strip.empty?

      url_token = SecureRandom.hex(16)
      payment_link = account.payment_links.create!(
        public_id: "pl_#{url_token}",
        url_token:,
        status: "active",
        description:,
        amount_cents:,
        currency:
      )

      Result.new(payment_link:, error: nil)
    end

    private

    attr_reader :account, :description, :amount_cents, :currency

    def positive_amount?
      amount_cents.to_i.positive?
    end

    def failure(error)
      Result.new(payment_link: nil, error:)
    end
  end
end
