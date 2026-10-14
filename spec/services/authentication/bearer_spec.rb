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
      expect(result).to eq(account)
    end

    context "when the digest does not match" do
      let(:raw_token) { "wrong-token" }

      it "returns nil" do
        expect(result).to be_nil
      end
    end

    context "when the account id differs" do
      let(:account_id) { "loja-xyz" }

      it "returns nil" do
        expect(result).to be_nil
      end
    end

    context "when the account is not credentialed" do
      let(:account) { create(:account, :uncredentialed, id: "loja-abc") }

      it "returns nil" do
        expect(result).to be_nil
      end
    end
  end
end
