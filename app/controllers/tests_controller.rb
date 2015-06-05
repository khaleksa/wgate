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
    # HTTParty.post('http://requestb.in/r1f3f9r1',
                 :query => params,
                 :body => payment_data.to_json,
                 :headers => { 'Content-Type' => 'application/json' })

    render :nothing => true, :status => 200
  end

  def sync_users
    provider = Provider.where(name: 'itest').first

    sync_date = provider.sync_user_timestamp.present? ? provider.sync_user_timestamp.strftime('%d-%m-%Y %H:%M') : ''
    params = {
        :name => provider.name,
        :password => provider.password_md5,
        :sync_date => sync_date
    }

    HTTParty.get(provider.sync_user_url, query: params)

    render :nothing => true, :status => 200
  end
end
