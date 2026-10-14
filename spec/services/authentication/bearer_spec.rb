require "rails_helper"

RSpec.describe Authentication::Bearer do
  describe ".call" do
    subject(:result) { described_class.call(raw_token:, account_id:) }

    let(:account) { create(:account, id: "loja-abc") }
    let(:raw_token) { "token-loja-abc" }
    let(:account_id) { account.id }

    before do
      create(:access_token, account:, raw_token: "token-loja-abc")
    end

    it "returns the account when the digest, account, and credential match" do
      expect(result).to be_success
      expect(result.account).to eq(account)
    end

    context "when the token is missing" do
      let(:raw_token) { "" }

      it "refuses before creation" do
        expect(result).not_to be_success
        expect(result.status).to eq(:unauthorized)
        expect(result.message).to eq("Não autorizado")
      end
    end

    context "when the digest does not match" do
      let(:raw_token) { "wrong-token" }

      it "refuses before creation" do
        expect(result).not_to be_success
        expect(result.status).to eq(:unauthorized)
      end
    end

    context "when the account id differs" do
      let(:account_id) { "loja-xyz" }

      it "refuses without naming the other account" do
        expect(result).not_to be_success
        expect(result.status).to eq(:forbidden)
        expect(result.message).to eq("Não autorizado")
        expect(result.message).not_to include("loja-xyz")
      end
    end

    context "when the account is not credentialed" do
      let(:account) { create(:account, :uncredentialed, id: "loja-abc") }

      it "refuses with the credential message" do
        expect(result).not_to be_success
        expect(result.status).to eq(:forbidden)
        expect(result.message).to eq("A conta precisa estar credenciada")
      end
    end
  end
end
