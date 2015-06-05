class TestsController < ApplicationController
  skip_before_action :verify_authenticity_token
  force_ssl if: :ssl_configured?

  def index

  end

  def echo_params
    render json: params
  end

  def payment_notification
    provider = Provider.where(name: 'itest').first

    params = {
        :name => provider.name,
        :password => provider.password_md5
    }
    payment_data = {
        payment: {
            :id => 123,
            :payment_system => 'paynet',
            :account_id => '998909124613',
            :amount => 15000,
            :status => 'commited'
        }
    }

    HTTParty.post(provider.sync_transaction_url,
                 :query => params,
                 :body => payment_data.to_json,
                 :headers => { 'Content-Type' => 'application/json' })

    render :nothing => true, :status => 200
  end
end
