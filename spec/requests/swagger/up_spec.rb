require "swagger_helper"

RSpec.describe "GET /up", type: :request do
  path "/up" do
    get "application health" do
      produces "application/json"

      response "200", "up" do
        schema type: :object,
          properties: {
            status: { type: :string, enum: [ "up" ] },
            timestamp: { type: :string, format: "date-time" }
          },
          required: %w[status timestamp]

        example "application/json", :up, {
          status: "up",
          timestamp: "2026-10-14T21:00:00Z"
        }

        run_test! do |response|
          body = JSON.parse(response.body)
          expect(body["status"]).to eq("up")
          expect(Time.iso8601(body["timestamp"])).to be_a(Time)
        end
      end
    end
  end
end
