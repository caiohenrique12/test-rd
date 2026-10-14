require "rails_helper"

RSpec.describe PaymentLinks::Creator do
  describe ".call" do
    subject(:payment_link) { described_class.call(account:, description:, amount_cents:, currency:) }

    let(:account) { create(:account, id: "loja-abc") }
    let(:description) { "Consultoria 1 hora" }
    let(:amount_cents) { 15_000 }
    let(:currency) { "BRL" }
    let(:url_token) { "8f3a2c1b4d5e6f708192a3b4c5d6e7f8" }

    before do
      allow(SecureRandom).to receive(:hex).with(16).and_return(url_token)
    end

    it "persists an active link for the account" do
      expect(payment_link).to be_persisted
      expect(payment_link.account).to eq(account)
      expect(payment_link.status).to eq("active")
      expect(payment_link.description).to eq("Consultoria 1 hora")
      expect(payment_link.amount_cents).to eq(15_000)
      expect(payment_link.currency).to eq("BRL")
    end

    it "builds an opaque public id from the url token" do
      expect(payment_link.public_id).to eq("pl_#{url_token}")
      expect(payment_link.url_token).to eq(url_token)
      expect(payment_link.url_token).not_to eq(account.id)
      expect(payment_link.url_token).not_to eq("token-loja-abc")
      expect(payment_link.public_url).to eq("https://pay.example.com/c/#{url_token}")
    end
  end
end
