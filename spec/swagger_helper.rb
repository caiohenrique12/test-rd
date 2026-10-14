# docker compose run --rm web bundle exec rake rswag:specs:swaggerize
require "rails_helper"

RSpec.configure do |config|
  config.openapi_root = Rails.root.join("swagger").to_s

  config.openapi_specs = {
    "v1/swagger.json" => {
      openapi: "3.0.1",
      info: {
        title: "API de pagamentos",
        version: "v1"
      },
      paths: {},
      servers: [
        { url: "http://localhost:3000" }
      ],
      components: {
        securitySchemes: {
          bearer_auth: {
            type: :http,
            scheme: :bearer
          }
        }
      }
    }
  }

  config.openapi_format = :json
end
