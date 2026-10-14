require "bigdecimal"

Given("que o produto de pagamentos aceita a moeda {string}") do |currency|
  @accepted_currency = currency
end

Given("a classe de autenticação valida Bearer, conta e se a conta está credenciada") do
  @authentication_required = true
end

Given("que o lojista da conta {string} está autenticado") do |account_id|
  remember_authenticated_account(account_id)
end

Given("que o lojista autenticado pertence somente à conta {string}") do |account_id|
  remember_authenticated_account(account_id)
end

Given("a conta {string} está credenciada para receber") do |_account_id|
  @credentialed = true
end

Given("a conta {string} ainda não está credenciada para receber") do |_account_id|
  @credentialed = false
end

When("ele solicita um link de pagamento com:") do |table|
  fields = table.rows_hash

  post_payment_link(
    account_id: @account_id,
    description: fields.fetch("descrição"),
    amount: amount_cents(fields.fetch("valor")),
    currency: fields.fetch("moeda")
  )
end

When("ele solicita um link de pagamento informando a conta {string}") do |account_id|
  post_payment_link(
    account_id: account_id,
    description: "Consultoria 1 hora",
    amount: amount_cents("150.00"),
    currency: "BRL"
  )
end

Then("o sistema cria um link ativo pertencente à conta {string}") do |account_id|
  expect(last_response.status).to eq(201)

  body = json_body
  expect(body["account_id"]).to eq(account_id)
  expect(body["status"]).to eq("active")
  expect(payment_links_count(account_id)).to eq(1)
end

Then("devolve uma URL única e opaca para esse link") do
  body = json_body
  url = body.fetch("url")
  id = body.fetch("id")

  expect(url).to match(%r{\Ahttps://pay\.example\.com/c/[^/]+\z})
  expect(url).not_to include(@account_id)
  expect(id).to match(/\Apl_/)
  expect(url.split("/").last).to eq(id.delete_prefix("pl_"))
end

Then("o valor cobrável do link é 150.00 BRL") do
  body = json_body
  expect(body["amount"]).to eq(15_000)
  expect(body["currency"]).to eq("BRL")
end

Then("a descrição do link é {string}") do |description|
  expect(json_body["description"]).to eq(description)
end

Then("o sistema recusa a criação") do
  expect(last_response.status).to eq(403).or eq(422)
end

Then("não persiste link") do
  expect(payment_links_count).to eq(0)
end

Then("informa que o valor deve ser maior que zero") do
  expect(last_response.status).to eq(422)
  expect(json_body["error"]).to include("O valor deve ser maior que zero")
end

Then("informa que a descrição é obrigatória") do
  expect(last_response.status).to eq(422)
  expect(json_body["error"]).to include("A descrição é obrigatória")
end

Then("informa que a conta precisa estar credenciada") do
  expect(last_response.status).to eq(403)
  expect(json_body["error"]).to include("A conta precisa estar credenciada")
end

Then("não persiste link na conta {string}") do |account_id|
  expect(payment_links_count(account_id)).to eq(0)
end

Then("não vaza existência ou dados da conta {string}") do |account_id|
  expect(last_response.status).to eq(403)
  expect(last_response.body).not_to include(account_id)
end

def remember_authenticated_account(account_id)
  @account_id = account_id
  @raw_token = "token-#{account_id}"
end

def amount_cents(valor)
  (BigDecimal(valor) * 100).to_i
end

def post_payment_link(account_id:, description:, amount:, currency:)
  # The header sends the raw token. Later issues persist its SHA-256 digest.
  header "Authorization", "Bearer #{@raw_token}"
  header "Content-Type", "application/json"
  post "/accounts/#{account_id}/payment_links", { description:, amount:, currency: }.to_json
end

def json_body
  JSON.parse(last_response.body)
end

def payment_links_count(account_id = nil)
  connection = ActiveRecord::Base.connection
  return 0 unless connection.data_source_exists?("payment_links")

  connection.select_value(payment_links_count_sql(connection, account_id)).to_i
end

def payment_links_count_sql(connection, account_id)
  if account_id && connection.column_exists?(:payment_links, :account_id)
    ActiveRecord::Base.sanitize_sql_array(
      [ "SELECT COUNT(*) FROM payment_links WHERE account_id = ?", account_id ]
    )
  else
    "SELECT COUNT(*) FROM payment_links"
  end
end
