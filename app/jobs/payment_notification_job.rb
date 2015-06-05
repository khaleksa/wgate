class PaymentNotificationJob < ActiveJob::Base
  queue_as :default

  def perform(provider_id, payment_data)
    provider = Provider.find(provider_id)
    return if provider.sync_transaction_url.blank?

    params = {
        :name => provider.name,
        :password => provider.password_md5,
        :payment => payment_data
    }

    result = HTTParty.post(provider.sync_transaction_url,
                           :body => params.to_json,
                           :headers => { 'Content-Type' => 'application/json' })

    Rails.logger.info "PaymentNotificationJob#perform: url: #{provider.sync_transaction_url}, send_data: #{params}, response_status:#{result.code}"
  end
end
