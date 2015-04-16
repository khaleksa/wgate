class PaynetsController < ApplicationController
  skip_before_action :verify_authenticity_token, if: :json_request?
  # force_ssl

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
    path = File.join Rails.public_path, 'ProviderWebService.wsdl'
    xml = File.read path
    render text: xml.html_safe, content_type: 'text/xml'
  end

  def action
    binding.pry

    action_header = request.headers['SOAPAction']
    action_name = action_header.gsub('urn:', '').gsub('"', '').underscore

    if self.respond_to?(action_name, true)
      xml = "<?xml version='1.0' encoding='UTF-8'?>\n"
      response = xml + send(action_name)
      render text: response, content_type: 'text/xml'
    else
      head :not_found
    end
  end

  private

  def perform_transaction
    timestamp = Time.now
    transaction_id = 0

    begin
      perform_tran_params = params['Envelope']['Body']['PerformTransactionArguments']
      @paynet_status = 0
      pt = PaynetTransaction.create! account_id: perform_tran_params['parameters']['paramValue'],
                                     amount: perform_tran_params['amount'],
                                     message: MESSAGES[@paynet_status],
                                     paynet_timestamp: perform_tran_params['transactionTime'],
                                     paynet_transaction_id: perform_tran_params['transactionId'],
                                     service_number: perform_tran_params['serviceId'],
                                     paynet_status: @paynet_status,
                                     status: 1,
                                     user_name: perform_tran_params['username'],
                                     password: perform_tran_params['password']
      transaction_id = pt.id
      timestamp = pt.created_at
    rescue Exception => err
      @paynet_status = 102
    ensure
      return envelope('PerformTransactionResult', pack_params(
                                                    errorMsg: MESSAGES[@paynet_status],
                                                    status: @paynet_status,
                                                    timeStamp: timestamp.to_s(:w3cdtf),
                                                    providerTrnId: transaction_id))
    end
  end

  def pack_params(args = {})
    args.map { |k, v| "<#{k}>#{v}</#{k}>\n" }.join
  end

  def envelope(name, body)
    "<soapenv:Envelope xmlns:soapenv='http://schemas.xmlsoap.org/soap/envelope/'>\n<soapenv:Body>\n" +
        "<ns1:#{name} xmlns:ns1='http://uws.provider.com/' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>\n" +
        body +
        "</ns1:#{name}>\n" +
        "</soapenv:Body>\n</soapenv:Envelope>"
  end

  def json_request?
    true
  end
end
