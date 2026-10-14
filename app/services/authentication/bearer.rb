module Authentication
  class Bearer < ApplicationService
    def initialize(raw_token:, account_id:)
      @raw_token = raw_token
      @account_id = account_id
    end

    def call
      return if raw_token.blank?

      access_token = AccessToken.find_by(
        token_digest: Digest::SHA256.hexdigest(raw_token),
        account_id:
      )
      account = access_token&.account
      account if account&.credentialed?
    end

    private

    attr_reader :raw_token, :account_id
  end
end
