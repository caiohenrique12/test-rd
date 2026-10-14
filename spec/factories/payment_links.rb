FactoryBot.define do
  factory :payment_link do
    account
    sequence(:url_token) { |n| "a#{format("%031x", n)}" }
    public_id { "pl_#{url_token}" }
    description { "Consultoria 1 hora" }
    amount_cents { 15_000 }
    currency { "BRL" }

    trait :active do
      status { "active" }
    end
  end
end
