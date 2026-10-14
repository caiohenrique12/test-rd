require "rails_helper"

RSpec.describe Account do
  describe "associations" do
    it { is_expected.to have_many(:access_tokens).dependent(:destroy) }
    it { is_expected.to have_many(:payment_links).dependent(:destroy) }
  end

  describe "primary key" do
    it "uses the public string id" do
      account = create(:account, id: "loja-abc")

      expect(account.id).to eq("loja-abc")
      expect(account.column_for_attribute("id").type).to eq(:string)
    end
  end

  describe "credentialed" do
    it "defaults the factory to a credentialed account" do
      expect(build(:account)).to be_credentialed
    end

    it "builds an uncredentialed account" do
      expect(build(:account, :uncredentialed)).not_to be_credentialed
    end
  end
end
