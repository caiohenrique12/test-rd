class ApplicationController < ActionController::API
  private

  def authenticate_account!
    authentication = Authentication::Bearer.call(raw_token:, account_id: params[:account_id])
    if authentication.success?
      @current_account = authentication.account
      return
    end

    render json: { error: authentication.message }, status: authentication.status
  end

  def current_account
    @current_account
  end

  def raw_token
    request.authorization.to_s[/\ABearer (.+)\z/, 1]
  end
end
