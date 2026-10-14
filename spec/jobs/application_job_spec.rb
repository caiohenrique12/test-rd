require "rails_helper"

RSpec.describe ApplicationJob do
  it "inherits from Active Job" do
    expect(described_class).to be < ActiveJob::Base
  end
end
