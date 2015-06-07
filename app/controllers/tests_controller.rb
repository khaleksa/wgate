class TestsController < ApplicationController
  skip_before_action :verify_authenticity_token
  force_ssl if: :ssl_configured?

  def index

  end

  def echo_params
    render json: params
  end

  def payment_notification
    render :nothing => true, :status => 200
  end

  def sync_users
    render :nothing => true, :status => 200
  end
end
