class PaymentNotificationJob < ActiveJob::Base
  queue_as :default

  def perform(provider_id, payment_data)
    provider = Provider.find(provider_id)
    return if provider.sync_transaction_url.blank?

    params = {
        :name => provider.name,
        :password => provider.password_md5,
        :payment => sync_payment_data(provider, payment_data)
    }
    result = HTTParty.post(provider.sync_transaction_url,
                           :body => params.to_json,
                           :headers => { 'Content-Type' => 'application/json' })

    Rails.logger.info "PaymentNotificationJob#perform: url: #{provider.sync_transaction_url}, send_data: #{params}, response_status:#{result.code}"
  end

  private
  def sync_payment_data(provider, payment_data)
    # This bad fix was done for 'itest' provider. 'itest' uses mobile number(12numbers) for account id.
    # '998' is add in the beginning of the account if user input only last 9 numbers of his account
    if provider.weak_account_verification && (payment_data[:account_id].to_s.size == 9)
      payment_data[:account_id] = '998' + payment_data[:account_id]
    end
    payment_data
  end
end
