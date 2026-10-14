require "rails_helper"

RSpec.describe "GET /status" do
  it "reports postgres and redis as healthy" do
    get status_path

    expect(response).to have_http_status(:ok)

    body = response.parsed_body
    expect(body["status"]).to eq("ok")
    expect(body.dig("checks", "postgres")).to eq("ok")
    expect(body.dig("checks", "redis")).to eq("ok")
  end
end
