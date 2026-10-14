FactoryBot.define do
  factory :access_token do
    account
    transient do
      raw_token { "token-#{account.id}" }
    end
    token_digest { Digest::SHA256.hexdigest(raw_token) }
  end
end
