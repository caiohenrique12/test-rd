module Authentication
  class Bearer < ApplicationService
    Result = Data.define(:account, :code) do
      def success?
        code.nil?
      end

      def status
        case code
        when :uncredentialed, :cross_tenant then :forbidden
        else :unauthorized
        end
      end

      def message
        if code == :uncredentialed
          "A conta precisa estar credenciada"
        else
          "Não autorizado"
        end
      end
    end

    def initialize(raw_token:, account_id:)
      @raw_token = raw_token
      @account_id = account_id
    end

    def call
      return Result.new(account: nil, code: :missing) if raw_token.blank?

      access_token = AccessToken.find_by(token_digest: Digest::SHA256.hexdigest(raw_token))
      return Result.new(account: nil, code: :unknown) if access_token.nil?

      account = access_token.account
      return Result.new(account:, code: :cross_tenant) if account.id != account_id
      return Result.new(account:, code: :uncredentialed) unless account.credentialed?

      Result.new(account:, code: nil)
    end

    private

    attr_reader :raw_token, :account_id
  end
end
