require "rails_helper"

RSpec.describe PaymentLink do
  describe "associations" do
    it { is_expected.to belong_to(:account) }
  end

  describe "validations" do
    subject { create(:payment_link) }

    it { is_expected.to validate_uniqueness_of(:public_id) }
    it { is_expected.to validate_uniqueness_of(:url_token) }
  end

  describe "status" do
    it "defaults to active" do
      expect(described_class.new.status).to eq("active")
      expect(build(:payment_link, :active).status).to eq("active")
    end
  end

  describe "#public_url" do
    it "joins the configured base url and the url token" do
      payment_link = build(:payment_link, url_token: "8f3a2c")

      expect(payment_link.public_url).to eq("https://pay.example.com/c/8f3a2c")
    end

    it "uses the configured payment link base url" do
      payment_link = build(:payment_link, url_token: "8f3a2c")
      original = Rails.configuration.x.payment_link_base_url
      Rails.configuration.x.payment_link_base_url = "https://pay.custom.test"

      expect(payment_link.public_url).to eq("https://pay.custom.test/c/8f3a2c")
    ensure
      Rails.configuration.x.payment_link_base_url = original
    end
  end
end
