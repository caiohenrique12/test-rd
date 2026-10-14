require "rails_helper"

RSpec.describe ApplicationMailer do
  it "sends from the default address" do
    expect(described_class.default[:from]).to eq("from@example.com")
  end
end
