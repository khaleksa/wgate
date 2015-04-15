class PaynetController < ApplictionController
  force_ssl

  MESSAGES = {
      0 => 'Успешно.',
      102 => 'Системная ошибка.',
      103 => 'Транзакция не найдена.',
      201 => 'Транзакция уже существует.',
      202 => 'Транзакция уже отменена.',
      302 => 'Клиент не найден.',
      411 => 'Не заданы один или несколько обязательных параметров.',
      412 => 'Неверный логин.',
      413 => 'Неверная сумма. Минимальная сумма - 1000 сум.',
      414 => 'Неверный формат даты и времени.'
  }

  def wsdl
    paynet_logger.debug "wsdl request. ip: #{request.remote_ip}"
    path = File.join Rails.public_path, 'ProviderWebService.wsdl'
    xml = File.read path
    render text: xml.html_safe, content_type: 'text/xml'
  end

  def action
    name = request.headers['SOAPAction']
    action = name.gsub('urn:', '').gsub('"', '').underscore

    if self.respond_to?(action, true)
      xml = "<?xml version='1.0' encoding='UTF-8'?>\n"
      response = xml + send(action)
      render text: response, content_type: 'text/xml'
    else
      head :not_found
    end

  end

  private
  create_table :paynet_transactions do |t|
    t.integer :status, null: false
    t.string :message
    t.integer :paynet_status
    t.string :user_name
    t.string :password
    t.integer :account_id
    t.integer :amount
    t.integer :service_number
    t.string :paynet_transaction_id, null: false
    t.datetime :paynet_timestamp
    t.string :ip
    t.timestamps null: false
  end
  def perform_transaction
    @system_error_msg = ''
    timestamp = Time.now
    transaction_id = 0
    begin
      @paynet_status = 0
      ActiveRecord::Base.transaction do
        pt = PaynetTransaction.create! account_id: agency_id,
                                       amount: amount,
                                       message: MESSAGES[@paynet_status] + @system_error_msg,
                                       paynet_timestamp: paynet_transaction_time,
                                       paynet_transaction_id: paynet_transaction_id,
                                       service_number: service_id,
                                       paynet_status: @paynet_status,
                                       status: 1,
                                       name: name,
                                       password: password
        transaction_id = pt.id
        timestamp = pt.created_at
      end
    rescue Exception => err
      @paynet_status = 102
      @system_error_msg = "; #{err.message}"
      paynet_logger.debug 'Error --------------------------------------'
      paynet_logger.debug err.message
    ensure
      return envelope('PerformTransactionResult', pack_params(
                                                    errorMsg: MESSAGES[@paynet_status],
                                                    status: @paynet_status,
                                                    timeStamp: timestamp.to_s(:w3cdtf),
                                                    providerTrnId: transaction_id))
    end
  end

end
