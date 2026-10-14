require "test_helper"
require "digest"

class PaymentLinksTest < ActionDispatch::IntegrationTest
  TOKEN = "token-loja-abc"

  test "credentialed merchant creates an active link with an opaque url" do
    create_merchant("loja-abc", credentialed: true, token: TOKEN)

    assert_difference -> { PaymentLink.count }, 1 do
      post_payment_link("loja-abc", token: TOKEN)
    end

    assert_response :created

    body = JSON.parse(response.body)
    assert_equal "loja-abc", body["account_id"]
    assert_equal "active", body["status"]
    assert_equal "Consultoria 1 hora", body["description"]
    assert_equal 15000, body["amount"]
    assert_equal "BRL", body["currency"]
    assert_match(/\Apl_/, body["id"])

    url_token = body["id"].delete_prefix("pl_")
    assert_equal "https://pay.example.com/c/#{url_token}", body["url"]
    assert_not_includes body["url"], "loja-abc"

    link = PaymentLink.find_by!(account_id: "loja-abc")
    assert_equal "active", link.status
    assert_equal "Consultoria 1 hora", link.description
    assert_equal 15000, link.amount_cents
    assert_equal "BRL", link.currency
    assert_equal body["id"], link.public_id
    assert_equal url_token, link.url_token
  end

  test "zero amount does not create a link" do
    create_merchant("loja-abc", credentialed: true, token: TOKEN)

    assert_no_difference -> { PaymentLink.count } do
      post_payment_link("loja-abc", token: TOKEN, amount: 0)
    end

    assert_response :unprocessable_entity
    assert_match(/maior que zero/i, error_message)
  end

  test "negative amount does not create a link" do
    create_merchant("loja-abc", credentialed: true, token: TOKEN)

    assert_no_difference -> { PaymentLink.count } do
      post_payment_link("loja-abc", token: TOKEN, amount: -1)
    end

    assert_response :unprocessable_entity
    assert_match(/maior que zero/i, error_message)
  end

  test "non integer amount does not create a link" do
    create_merchant("loja-abc", credentialed: true, token: TOKEN)

    assert_no_difference -> { PaymentLink.count } do
      post_payment_link("loja-abc", token: TOKEN, amount: 150.5)
    end

    assert_response :unprocessable_entity
    assert_match(/maior que zero/i, error_message)
  end

  test "blank description does not create a link" do
    create_merchant("loja-abc", credentialed: true, token: TOKEN)

    assert_no_difference -> { PaymentLink.count } do
      post_payment_link("loja-abc", token: TOKEN, description: "")
    end

    assert_response :unprocessable_entity
    assert_match(/descri..o.*obrigat/i, error_message)
  end

  test "whitespace description does not create a link" do
    create_merchant("loja-abc", credentialed: true, token: TOKEN)

    assert_no_difference -> { PaymentLink.count } do
      post_payment_link("loja-abc", token: TOKEN, description: "   ")
    end

    assert_response :unprocessable_entity
    assert_match(/descri..o.*obrigat/i, error_message)
  end

  test "description longer than 140 characters does not create a link" do
    create_merchant("loja-abc", credentialed: true, token: TOKEN)

    assert_no_difference -> { PaymentLink.count } do
      post_payment_link("loja-abc", token: TOKEN, description: "a" * 141)
    end

    assert_response :unprocessable_entity
  end

  test "unsupported currency does not create a link" do
    create_merchant("loja-abc", credentialed: true, token: TOKEN)

    assert_no_difference -> { PaymentLink.count } do
      post_payment_link("loja-abc", token: TOKEN, currency: "USD")
    end

    assert_response :unprocessable_entity
    assert_match(/moeda/i, error_message)
  end

  test "uncredentialed account does not create a link" do
    create_merchant("loja-abc", credentialed: false, token: TOKEN)

    assert_no_difference -> { PaymentLink.count } do
      post_payment_link("loja-abc", token: TOKEN)
    end

    assert_response :forbidden
    assert_match(/credenciada/i, error_message)
  end

  test "token from one account does not create a link on another" do
    create_merchant("loja-abc", credentialed: true, token: TOKEN)
    create_merchant("loja-xyz", credentialed: true, token: "token-loja-xyz")

    assert_no_difference -> { PaymentLink.count } do
      post_payment_link("loja-xyz", token: TOKEN)
    end

    assert_response :forbidden
    assert_not_includes response.body, "loja-xyz"
    assert_nil PaymentLink.find_by(account_id: "loja-xyz")
  end

  test "missing bearer does not create a link" do
    create_merchant("loja-abc", credentialed: true, token: TOKEN)

    assert_no_difference -> { PaymentLink.count } do
      post_payment_link("loja-abc")
    end

    assert_response :unauthorized
  end

  test "unknown bearer does not create a link" do
    create_merchant("loja-abc", credentialed: true, token: TOKEN)

    assert_no_difference -> { PaymentLink.count } do
      post_payment_link("loja-abc", token: "token-desconhecido")
    end

    assert_response :unauthorized
  end

  private

  def create_merchant(id, credentialed:, token:)
    account = Account.create!(id: id, credentialed: credentialed)
    AccessToken.create!(
      account: account,
      token_digest: Digest::SHA256.hexdigest(token)
    )
    account
  end

  def post_payment_link(account_id, token: nil, **overrides)
    headers = {}
    headers["Authorization"] = "Bearer #{token}" if token

    post "/accounts/#{account_id}/payment_links",
      params: {
        description: "Consultoria 1 hora",
        amount: 15000,
        currency: "BRL"
      }.merge(overrides),
      headers: headers,
      as: :json
  end

  def error_message
    JSON.parse(response.body).fetch("error")
  end
end
