require "swagger_helper"

RSpec.describe "GET /status", type: :request do
  path "/status" do
    get "dependency status" do
      produces "application/json"

      response "200", "ok" do
        schema type: :object,
          properties: {
            status: { type: :string, enum: %w[ok degraded] },
            checks: {
              type: :object,
              properties: {
                postgres: { type: :string, enum: %w[ok error] },
                redis: { type: :string, enum: %w[ok error] }
              },
              required: %w[postgres redis]
            }
          },
          required: %w[status checks]

        example "application/json", :ok, {
          status: "ok",
          checks: { postgres: "ok", redis: "ok" }
        }

        run_test! do |response|
          expect(JSON.parse(response.body)).to eq(
            "status" => "ok",
            "checks" => { "postgres" => "ok", "redis" => "ok" }
          )
        end
      end

      response "503", "degraded" do
        schema type: :object,
          properties: {
            status: { type: :string, enum: %w[ok degraded] },
            checks: {
              type: :object,
              properties: {
                postgres: { type: :string, enum: %w[ok error] },
                redis: { type: :string, enum: %w[ok error] }
              },
              required: %w[postgres redis]
            }
          },
          required: %w[status checks]

        example "application/json", :postgres_down, {
          status: "degraded",
          checks: { postgres: "error", redis: "ok" }
        }
        example "application/json", :redis_down, {
          status: "degraded",
          checks: { postgres: "ok", redis: "error" }
        }

        context "when postgres is unavailable" do
          before do
            allow(ActiveRecord::Base.connection).to receive(:select_value).and_wrap_original do |method, *args|
              raise StandardError, "db down" if args.first == "SELECT 1"

              method.call(*args)
            end
          end

          run_test! do |response|
            expect(JSON.parse(response.body)).to eq(
              "status" => "degraded",
              "checks" => { "postgres" => "error", "redis" => "ok" }
            )
          end
        end

        context "when redis is unavailable" do
          before do
            allow(Redis).to receive(:new).and_raise(StandardError, "connection refused")
          end

          run_test! do |response|
            expect(JSON.parse(response.body)).to eq(
              "status" => "degraded",
              "checks" => { "postgres" => "ok", "redis" => "error" }
            )
          end
        end
      end
    end
  end
end
