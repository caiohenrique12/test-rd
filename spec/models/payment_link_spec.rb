require "rails_helper"

RSpec.describe PaymentLink do
  describe "associations" do
    it { is_expected.to belong_to(:account) }
  end

  describe "validations" do
    subject { create(:payment_link) }

    it { is_expected.to validate_uniqueness_of(:public_id) }
    it { is_expected.to validate_uniqueness_of(:url_token) }

    it "is valid for a normal factory link" do
      expect(build(:payment_link)).to be_valid
    end

    context "when the amount is zero" do
      subject(:payment_link) { build(:payment_link, amount_cents: 0) }

      it "is invalid" do
        expect(payment_link).not_to be_valid
        expect(payment_link.errors[:base]).to include("O valor deve ser maior que zero")
      end
    end

    context "when the amount is negative" do
      subject(:payment_link) { build(:payment_link, amount_cents: -100) }

      it "is invalid" do
        expect(payment_link).not_to be_valid
        expect(payment_link.errors[:base]).to include("O valor deve ser maior que zero")
      end
    end

    context "when the amount is not an integer" do
      subject(:payment_link) { build(:payment_link, amount_cents: 15.5) }

      it "is invalid" do
        expect(payment_link).not_to be_valid
        expect(payment_link.errors[:base]).to include("O valor deve ser maior que zero")
      end
    end

    context "when the currency is not BRL" do
      subject(:payment_link) { build(:payment_link, currency: "USD") }

      it "is invalid" do
        expect(payment_link).not_to be_valid
        expect(payment_link.errors[:base]).to include("A moeda não é suportada")
      end
    end

    context "when the description is blank" do
      subject(:payment_link) { build(:payment_link, description: "") }

      it "is invalid" do
        expect(payment_link).not_to be_valid
        expect(payment_link.errors[:base]).to include("A descrição é obrigatória")
      end
    end

    context "when the description is only spaces" do
      subject(:payment_link) { build(:payment_link, description: "   ") }

      it "is invalid" do
        expect(payment_link).not_to be_valid
        expect(payment_link.errors[:base]).to include("A descrição é obrigatória")
      end
    end

    context "when the description is missing" do
      subject(:payment_link) { build(:payment_link, description: nil) }

      it "is invalid" do
        expect(payment_link).not_to be_valid
        expect(payment_link.errors[:base]).to include("A descrição é obrigatória")
      end
    end

    context "when the description is 140 characters" do
      subject(:payment_link) { build(:payment_link, description: "a" * 140) }

      it "is valid" do
        expect(payment_link).to be_valid
      end
    end

    context "when the description is 140 characters with surrounding spaces" do
      subject(:payment_link) { build(:payment_link, description: " #{"a" * 140} ") }

      it "is valid and stores the stripped description" do
        expect(payment_link).to be_valid
        expect(payment_link.description).to eq("a" * 140)
      end
    end

    context "when the description is longer than 140 characters" do
      subject(:payment_link) { build(:payment_link, description: "a" * 141) }

      it "is invalid" do
        expect(payment_link).not_to be_valid
        expect(payment_link.errors[:base]).to include("A descrição deve ter no máximo 140 caracteres")
      end
    end

    context "when the description is only spaces beyond the limit" do
      subject(:payment_link) { build(:payment_link, description: " " * 200) }

      it "is invalid because the description is required" do
        expect(payment_link).not_to be_valid
        expect(payment_link.errors[:base]).to include("A descrição é obrigatória")
        expect(payment_link.errors[:base]).not_to include("A descrição deve ter no máximo 140 caracteres")
      end
    end
  end

  describe "description column" do
    it "rejects a value longer than 140 characters" do
      payment_link = build(:payment_link, description: "a" * 141)

      expect { payment_link.save(validate: false) }.to raise_error(ActiveRecord::ValueTooLong)
    end
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
