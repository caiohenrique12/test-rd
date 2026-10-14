require "rails_helper"

RSpec.describe "API docs" do
  it "opens the Swagger UI" do
    get "/api-docs"

    expect(response).to have_http_status(:moved_permanently)
    follow_redirect!

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Swagger UI")
  end

  it "serves the OpenAPI document for the three endpoints" do
    get "/api-docs/v1/swagger.json"

    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq("application/json")

    body = response.body
    expect(body).to include("/up")
    expect(body).to include("/status")
    expect(body).to include("/accounts/{account_id}/payment_links")
    expect(body).to include("15000")
    expect(body).to include("BRL")
    expect(body).to include("Bearer")
    expect(body).to include("O valor deve ser maior que zero")
    expect(body).to include("A descrição é obrigatória")
    expect(body).to include("A moeda não é suportada")
    expect(body).to include("A conta precisa estar credenciada")
  end
end
