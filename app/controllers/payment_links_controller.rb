class PaymentLinksController < ApplicationController
  before_action :authenticate_account!

  def create
    result = PaymentLinks::Creator.call(
      account: current_account,
      description: payment_link_params[:description],
      amount_cents: payment_link_params[:amount],
      currency: payment_link_params[:currency]
    )

    render json: result, status: result.success? ? :created : :unprocessable_content
  end

  private

  def payment_link_params
    params.permit(:description, :amount, :currency)
  end
end
