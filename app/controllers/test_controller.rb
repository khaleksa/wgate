class TestController < ApplicationController
  skip_before_action :verify_authenticity_token

  def echo_params
    render json: params
  end
end
