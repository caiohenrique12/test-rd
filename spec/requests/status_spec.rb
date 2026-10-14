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

  context "when postgres is unavailable" do
    it "reports a degraded status" do
      allow(ActiveRecord::Base.connection).to receive(:select_value).and_wrap_original do |method, *args|
        raise StandardError, "db down" if args.first == "SELECT 1"

        method.call(*args)
      end

      get status_path

      expect(response).to have_http_status(:service_unavailable)
      body = response.parsed_body
      expect(body["status"]).to eq("degraded")
      expect(body.dig("checks", "postgres")).to eq("error")
      expect(body.dig("checks", "redis")).to eq("ok")
    end
  end

  context "when redis is unavailable" do
    it "reports a degraded status" do
      allow(Redis).to receive(:new).and_raise(StandardError, "connection refused")

      get status_path

      expect(response).to have_http_status(:service_unavailable)
      body = response.parsed_body
      expect(body["status"]).to eq("degraded")
      expect(body.dig("checks", "postgres")).to eq("ok")
      expect(body.dig("checks", "redis")).to eq("error")
    end
  end
end
