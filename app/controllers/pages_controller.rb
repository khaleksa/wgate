class PagesController < ApplicationController
  http_basic_authenticate_with name: "pays", password: "system"

  skip_before_action :verify_authenticity_token
  force_ssl if: :ssl_configured?

  def index
    @payments = Payment.where(provider_id: 3, status: 'commited')
    @total_amount = @payments.pluck(:amount).sum
  end

  def access_errors
    @account_errors = AccessError.where(provider_id: 3)
  end
end
