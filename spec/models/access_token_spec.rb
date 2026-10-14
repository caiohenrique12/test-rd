require "rails_helper"

RSpec.describe AccessToken do
  describe "associations" do
    it { is_expected.to belong_to(:account) }
  end

  describe "validations" do
    subject { build(:access_token) }

    it { is_expected.to validate_presence_of(:token_digest) }
    it { is_expected.to validate_uniqueness_of(:token_digest) }
  end

  describe "token digest" do
    it "stores the SHA-256 hex digest of the raw token" do
      raw_token = "token-loja-abc"
      access_token = create(:access_token, raw_token:)

      expect(access_token.token_digest).to eq(Digest::SHA256.hexdigest(raw_token))
      expect(access_token.token_digest).not_to eq(raw_token)
    end
  end
end
