class TransactionNotificationJob < ActiveJob::Base
  queue_as :default

  def peform(url, send_data)
    result = HTTParty.post(url,
                           :body => send_data,
                           :headers => { 'Content-Type' => 'application/json' }
                           )
    logger.info "Url: #{url}, SendData: #{send_data}"
  end
end
