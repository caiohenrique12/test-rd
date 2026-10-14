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
end
