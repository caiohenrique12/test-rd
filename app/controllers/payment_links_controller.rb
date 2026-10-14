class PaymentLinksController < ApplicationController
  def create
    account = Authentication::Bearer.call(raw_token:, account_id: params[:account_id])
    return head :not_found if account.nil?

    payment_link = PaymentLinks::Creator.call(
      account:,
      description: payment_link_params[:description],
      amount_cents: payment_link_params[:amount],
      currency: payment_link_params[:currency]
    )

    render json: payment_link_response(payment_link), status: :created
  end

  private

  def raw_token
    request.authorization.to_s[/\ABearer (.+)\z/, 1]
  end

  def payment_link_params
    params.permit(:description, :amount, :currency)
  end

  def payment_link_response(payment_link)
    {
      id: payment_link.public_id,
      account_id: payment_link.account_id,
      status: payment_link.status,
      description: payment_link.description,
      amount: payment_link.amount_cents,
      currency: payment_link.currency,
      url: payment_link.public_url
    }
  end
end
