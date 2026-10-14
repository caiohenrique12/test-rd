require "rails_helper"

RSpec.describe "POST /accounts/:account_id/payment_links" do
  it "creates an active payment link for a credentialed merchant" do
    account = create(:account, id: "loja-abc")
    raw_token = "token-loja-abc"
    create(:access_token, account:, raw_token:)
    url_token = "8f3a2c1b4d5e6f708192a3b4c5d6e7f8"
    allow(SecureRandom).to receive(:hex).with(16).and_return(url_token)

    post "/accounts/loja-abc/payment_links",
      params: {
        description: "Consultoria 1 hora",
        amount: 15_000,
        currency: "BRL"
      },
      headers: { "Authorization" => "Bearer #{raw_token}" },
      as: :json

    expect(response).to have_http_status(:created)

    payment_link = PaymentLink.find_by!(account_id: "loja-abc")
    expect(payment_link.amount_cents).to eq(15_000)
    expect(payment_link.description).to eq("Consultoria 1 hora")
    expect(payment_link.status).to eq("active")
    expect(payment_link.currency).to eq("BRL")

    expect(response.parsed_body).to eq(
      "id" => "pl_#{url_token}",
      "account_id" => "loja-abc",
      "status" => "active",
      "description" => "Consultoria 1 hora",
      "amount" => 15_000,
      "currency" => "BRL",
      "url" => "https://pay.example.com/c/#{url_token}"
    )
    expect(response.parsed_body["url"]).not_to include("loja-abc")
    expect(response.parsed_body["id"]).to eq("pl_#{payment_link.url_token}")
  end

  context "when the bearer is unknown" do
    it "responds with unauthorized and does not create a link" do
      create(:account, id: "loja-abc")

      post "/accounts/loja-abc/payment_links",
        params: {
          description: "Consultoria 1 hora",
          amount: 15_000,
          currency: "BRL"
        },
        headers: { "Authorization" => "Bearer wrong-token" },
        as: :json

      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body["error"]).to eq("Não autorizado")
      expect(PaymentLink.count).to eq(0)
    end
  end

  context "when the token belongs to another account" do
    it "responds with forbidden and does not leak the url account" do
      account = create(:account, id: "loja-abc")
      create(:access_token, account:, raw_token: "token-loja-abc")

      post "/accounts/loja-xyz/payment_links",
        params: {
          description: "Consultoria 1 hora",
          amount: 15_000,
          currency: "BRL"
        },
        headers: { "Authorization" => "Bearer token-loja-abc" },
        as: :json

      expect(response).to have_http_status(:forbidden)
      expect(response.body).not_to include("loja-xyz")
      expect(PaymentLink.count).to eq(0)
    end
  end

  context "when the account is not credentialed" do
    it "responds with forbidden" do
      account = create(:account, :uncredentialed, id: "loja-abc")
      create(:access_token, account:, raw_token: "token-loja-abc")

      post "/accounts/loja-abc/payment_links",
        params: {
          description: "Consultoria 1 hora",
          amount: 15_000,
          currency: "BRL"
        },
        headers: { "Authorization" => "Bearer token-loja-abc" },
        as: :json

      expect(response).to have_http_status(:forbidden)
      expect(response.parsed_body["error"]).to eq("A conta precisa estar credenciada")
      expect(PaymentLink.count).to eq(0)
    end
  end

  context "when the amount is zero" do
    it "responds with unprocessable entity" do
      account = create(:account, id: "loja-abc")
      create(:access_token, account:, raw_token: "token-loja-abc")

      post "/accounts/loja-abc/payment_links",
        params: {
          description: "Consultoria 1 hora",
          amount: 0,
          currency: "BRL"
        },
        headers: { "Authorization" => "Bearer token-loja-abc" },
        as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["error"]).to eq("O valor deve ser maior que zero")
      expect(PaymentLink.count).to eq(0)
    end
  end

  context "when the amount is negative" do
    it "responds with unprocessable entity" do
      account = create(:account, id: "loja-abc")
      create(:access_token, account:, raw_token: "token-loja-abc")

      post "/accounts/loja-abc/payment_links",
        params: {
          description: "Consultoria 1 hora",
          amount: -100,
          currency: "BRL"
        },
        headers: { "Authorization" => "Bearer token-loja-abc" },
        as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["error"]).to eq("O valor deve ser maior que zero")
      expect(PaymentLink.count).to eq(0)
    end
  end

  context "when the amount is not an integer" do
    it "responds with unprocessable entity" do
      account = create(:account, id: "loja-abc")
      create(:access_token, account:, raw_token: "token-loja-abc")

      post "/accounts/loja-abc/payment_links",
        params: {
          description: "Consultoria 1 hora",
          amount: 15.5,
          currency: "BRL"
        },
        headers: { "Authorization" => "Bearer token-loja-abc" },
        as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["error"]).to eq("O valor deve ser maior que zero")
      expect(PaymentLink.count).to eq(0)
    end
  end

  context "when the currency is not supported" do
    it "responds with unprocessable entity" do
      account = create(:account, id: "loja-abc")
      create(:access_token, account:, raw_token: "token-loja-abc")

      post "/accounts/loja-abc/payment_links",
        params: {
          description: "Consultoria 1 hora",
          amount: 15_000,
          currency: "USD"
        },
        headers: { "Authorization" => "Bearer token-loja-abc" },
        as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["error"]).to eq("A moeda não é suportada")
      expect(PaymentLink.count).to eq(0)
    end
  end

  context "when the description is blank" do
    it "responds with unprocessable entity" do
      account = create(:account, id: "loja-abc")
      create(:access_token, account:, raw_token: "token-loja-abc")

      post "/accounts/loja-abc/payment_links",
        params: {
          description: "",
          amount: 15_000,
          currency: "BRL"
        },
        headers: { "Authorization" => "Bearer token-loja-abc" },
        as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["error"]).to eq("A descrição é obrigatória")
      expect(PaymentLink.count).to eq(0)
    end
  end

  context "when the description is only spaces" do
    it "responds with unprocessable entity" do
      account = create(:account, id: "loja-abc")
      create(:access_token, account:, raw_token: "token-loja-abc")

      post "/accounts/loja-abc/payment_links",
        params: {
          description: "   ",
          amount: 15_000,
          currency: "BRL"
        },
        headers: { "Authorization" => "Bearer token-loja-abc" },
        as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["error"]).to eq("A descrição é obrigatória")
      expect(PaymentLink.count).to eq(0)
    end
  end

  context "when the description is missing" do
    it "responds with unprocessable entity" do
      account = create(:account, id: "loja-abc")
      create(:access_token, account:, raw_token: "token-loja-abc")

      post "/accounts/loja-abc/payment_links",
        params: {
          amount: 15_000,
          currency: "BRL"
        },
        headers: { "Authorization" => "Bearer token-loja-abc" },
        as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["error"]).to eq("A descrição é obrigatória")
      expect(PaymentLink.count).to eq(0)
    end
  end
end
