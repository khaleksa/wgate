class PaymentNotificationJob < ActiveJob::Base
  queue_as :default

  def perform(provider_id, payment_data)
    provider = Provider.find(provider_id)
    params = {
        :name => provider.name,
        :password => provider.password_md5
    }
    result = HTTParty.post(provider.sync_transaction_url,
                           :query => params,
                           :body => payment_data.to_json,
                           :headers => { 'Content-Type' => 'application/json' })
    logger.info "Url: #{provider.sync_transaction_url}, SendData: #{params}, response status:#{result.code}"
  end
end
