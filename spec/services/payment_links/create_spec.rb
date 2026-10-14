require "rails_helper"

RSpec.describe PaymentLinks::Creator do
  describe ".call" do
    subject(:result) { described_class.call(account:, description:, amount_cents:, currency:) }

    let(:account) { create(:account, id: "loja-abc") }
    let(:description) { "Consultoria 1 hora" }
    let(:amount_cents) { 15_000 }
    let(:currency) { "BRL" }
    let(:url_token) { "8f3a2c1b4d5e6f708192a3b4c5d6e7f8" }

    before do
      allow(SecureRandom).to receive(:hex).with(16).and_return(url_token)
    end

    it "persists an active link for the account" do
      payment_link = result.payment_link

      expect(result).to be_success
      expect(payment_link).to be_persisted
      expect(payment_link.account).to eq(account)
      expect(payment_link.status).to eq("active")
      expect(payment_link.description).to eq("Consultoria 1 hora")
      expect(payment_link.amount_cents).to eq(15_000)
      expect(payment_link.currency).to eq("BRL")
    end

    it "returns the created link as the success response" do
      expect(result.as_json).to eq(
        id: "pl_#{url_token}",
        account_id: "loja-abc",
        status: "active",
        description: "Consultoria 1 hora",
        amount: 15_000,
        currency: "BRL",
        url: "https://pay.example.com/c/#{url_token}"
      )
      expect(result.payment_link.url_token).to eq(url_token)
      expect(result.payment_link.url_token).not_to eq(account.id)
    end

    context "when the amount is not positive" do
      let(:amount_cents) { 0 }

      it "refuses and does not persist a link" do
        expect(result).not_to be_success
        expect(result.as_json).to eq(error: "O valor deve ser maior que zero")
        expect(PaymentLink.count).to eq(0)
      end
    end

    context "when the description is blank" do
      let(:description) { "" }

      it "refuses and does not persist a link" do
        expect(result).not_to be_success
        expect(result.as_json).to eq(error: "A descrição é obrigatória")
        expect(PaymentLink.count).to eq(0)
      end
    end
  end
end
