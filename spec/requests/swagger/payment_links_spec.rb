require "swagger_helper"

RSpec.describe "POST /accounts/{account_id}/payment_links", type: :request do
  path "/accounts/{account_id}/payment_links" do
    post "creates a payment link" do
      consumes "application/json"
      produces "application/json"
      security [ { bearer_auth: [] } ]
      parameter name: "Authorization", in: :header, required: false,
        description: "Bearer <raw token>",
        example: "Bearer token-loja-abc",
        schema: { type: :string }
      parameter name: :account_id, in: :path, schema: { type: :string }, example: "loja-abc"
      parameter name: :payment_link, in: :body, required: true, schema: {
        type: :object,
        properties: {
          description: { type: :string },
          amount: { type: :integer, description: "Amount in cents" },
          currency: { type: :string, enum: [ "BRL" ] }
        },
        required: %w[description amount currency]
      }
      request_body_example name: "consultoria", summary: "Consultoria 1 hora", value: {
        description: "Consultoria 1 hora",
        amount: 15_000,
        currency: "BRL"
      }

      let(:account_id) { "loja-abc" }
      let(:payment_link) do
        { description: "Consultoria 1 hora", amount: 15_000, currency: "BRL" }
      end

      response "201", "created" do
        schema type: :object,
          properties: {
            id: { type: :string },
            account_id: { type: :string },
            status: { type: :string, enum: [ "active" ] },
            description: { type: :string },
            amount: { type: :integer, description: "Amount in cents" },
            currency: { type: :string, enum: [ "BRL" ] },
            url: { type: :string }
          },
          required: %w[id account_id status description amount currency url]

        example "application/json", :created, {
          id: "pl_8f3a2c",
          account_id: "loja-abc",
          status: "active",
          description: "Consultoria 1 hora",
          amount: 15_000,
          currency: "BRL",
          url: "https://pay.example.com/c/8f3a2c"
        }

        let(:Authorization) { "Bearer token-loja-abc" }

        before do
          account = create(:account, id: "loja-abc")
          create(:access_token, account:, raw_token: "token-loja-abc")
          allow(SecureRandom).to receive(:hex).with(16).and_return("8f3a2c")
        end

        run_test! do |response|
          body = JSON.parse(response.body)
          expect(body).to eq(
            "id" => "pl_8f3a2c",
            "account_id" => "loja-abc",
            "status" => "active",
            "description" => "Consultoria 1 hora",
            "amount" => 15_000,
            "currency" => "BRL",
            "url" => "https://pay.example.com/c/8f3a2c"
          )
          expect(body["url"]).not_to include(body["account_id"])
        end
      end

      response "401", "unauthorized" do
        schema type: :object,
          properties: { error: { type: :string } },
          required: %w[error]

        example "application/json", :missing_authorization, { error: "Não autorizado" }
        example "application/json", :unknown_bearer, { error: "Não autorizado" }

        context "when the authorization header is missing" do
          before { create(:account, id: "loja-abc") }

          run_test! do |response|
            expect(JSON.parse(response.body)).to eq("error" => "Não autorizado")
          end
        end

        context "when the bearer is unknown" do
          let(:Authorization) { "Bearer wrong-token" }

          before { create(:account, id: "loja-abc") }

          run_test! do |response|
            expect(JSON.parse(response.body)).to eq("error" => "Não autorizado")
          end
        end
      end

      response "403", "forbidden" do
        schema type: :object,
          properties: { error: { type: :string } },
          required: %w[error]

        example "application/json", :uncredentialed, { error: "A conta precisa estar credenciada" }
        example "application/json", :other_account, { error: "Não autorizado" }

        context "when the account is not credentialed" do
          let(:Authorization) { "Bearer token-loja-abc" }

          before do
            account = create(:account, :uncredentialed, id: "loja-abc")
            create(:access_token, account:, raw_token: "token-loja-abc")
          end

          run_test! do |response|
            expect(JSON.parse(response.body)).to eq("error" => "A conta precisa estar credenciada")
          end
        end

        context "when the token belongs to another account" do
          let(:account_id) { "loja-xyz" }
          let(:Authorization) { "Bearer token-loja-abc" }

          before do
            account = create(:account, id: "loja-abc")
            create(:access_token, account:, raw_token: "token-loja-abc")
          end

          run_test! do |response|
            expect(response.body).not_to include("loja-xyz")
            expect(JSON.parse(response.body)).to eq("error" => "Não autorizado")
            response.headers.each do |name, value|
              expect("#{name} #{Array(value).join}").not_to include("loja-xyz")
            end
          end
        end
      end

      response "422", "unprocessable entity" do
        schema type: :object,
          properties: { error: { type: :string } },
          required: %w[error]

        example "application/json", :amount, { error: "O valor deve ser maior que zero" }
        example "application/json", :description, { error: "A descrição é obrigatória" }
        example "application/json", :currency, { error: "A moeda não é suportada" }

        let(:Authorization) { "Bearer token-loja-abc" }

        before do
          account = create(:account, id: "loja-abc")
          create(:access_token, account:, raw_token: "token-loja-abc")
        end

        context "when the amount is zero" do
          let(:payment_link) do
            { description: "Consultoria 1 hora", amount: 0, currency: "BRL" }
          end

          run_test! do |response|
            expect(JSON.parse(response.body)).to eq("error" => "O valor deve ser maior que zero")
          end
        end

        context "when the description is blank" do
          let(:payment_link) do
            { description: "", amount: 15_000, currency: "BRL" }
          end

          run_test! do |response|
            expect(JSON.parse(response.body)).to eq("error" => "A descrição é obrigatória")
          end
        end

        context "when the currency is not supported" do
          let(:payment_link) do
            { description: "Consultoria 1 hora", amount: 15_000, currency: "USD" }
          end

          run_test! do |response|
            expect(JSON.parse(response.body)).to eq("error" => "A moeda não é suportada")
          end
        end
      end
    end
  end
end
