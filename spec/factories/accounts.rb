FactoryBot.define do
  factory :account do
    sequence(:id) { |n| "loja-#{n}" }
    credentialed { true }

    trait :uncredentialed do
      credentialed { false }
    end
  end
end
