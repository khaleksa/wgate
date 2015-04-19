class PaynetsController < ApplicationController
  skip_before_action :verify_authenticity_token
  # force_ssl

  STATUS_MESSAGES = {
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

  XML_HEADER = "<?xml version='1.0' encoding='UTF-8'?>\n"

  def wsdl
    wsdl_path = File.join Rails.public_path, 'ProviderWebService.wsdl'
    wsdl_file = File.read wsdl_path
    render text: wsdl_file.html_safe, content_type: 'text/xml'
  end

  def action
    action_name = request.headers['SOAPAction'].gsub('urn:', '').gsub('"', '').underscore
    # params = Hash.from_xml(request.body.read)

    if self.respond_to?(action_name, true)
      response = XML_HEADER + send(action_name)
      render text: response, content_type: 'text/xml'
    else
      head :not_found
    end
  end

  def perform_transaction
    begin
      params = Hash.from_xml(request.body.read)
      perform_tran_params = params['Envelope']['Body']['PerformTransactionArguments']

      @paynet_status = 0
      create_params = {
        account_id: perform_tran_params['parameters']['paramValue'].to_i,
        transaction_id: perform_tran_params['transactionId'],
        transaction_timestamp: perform_tran_params['transactionTime'],
        service_id: perform_tran_params['serviceId'].to_i,
        state_status: PaynetTransaction::STATUS[:commit],
        response_status: @paynet_status,
        response_message: STATUS_MESSAGES[@paynet_status],
        amount: perform_tran_params['amount'].to_i,
        user_name: perform_tran_params['username'],
        password: perform_tran_params['password']
      }

      transaction = PaynetTransaction.create! create_params

      transaction_id = transaction.id
      timestamp = transaction.created_at
    rescue Exception => err
      @paynet_status = 102
      transaction_id = 0
      timestamp = Time.now
    ensure
      return envelope('PerformTransactionResult', pack_params(
                                                    errorMsg: STATUS_MESSAGES[@paynet_status],
                                                    status: @paynet_status,
                                                    timeStamp: timestamp.to_s(:w3cdtf),
                                                    providerTrnId: transaction_id))
    end
  end

  def check_transaction
    timestamp = Time.now

    begin
      params = Hash.from_xml(request.body.read)
      check_tran_params = params['Envelope']['Body']['CheckTransactionArguments']
      transaction = PaynetTransaction.find_by_transaction_id(check_tran_params['transactionId'])
      if transaction
        response_status = 0
        transaction_id = transaction.id
        transaction_state = transaction.state_status
        state_error_status = transaction.response_status
        state_error_message = transaction.response_message
      else
        #TODO ??? check values of params
        response_status = 103
        transaction_id = 0
        transaction_state = 0
        state_error_status = 0
        state_error_message = ''
      end
    rescue Exception => err
      response_status = 102
      transaction_id = 0
    ensure
      return envelope('CheckTransactionResult', pack_params(
                                                  errorMsg: STATUS_MESSAGES[response_status],
                                                  status: response_status,
                                                  timeStamp: timestamp.to_s(:w3cdtf),
                                                  providerTrnId: transaction_id,
                                                  transactionState: transaction_state,
                                                  transactionStateErrorStatus: state_error_status,
                                                  transactionStateErrorMsg: state_error_message))
    end
  end

  def cancel_transaction
    timestamp = Time.now
    state = 0
    begin
      @paynet_status = 0
      params = Hash.from_xml(request.body.read)
      cancel_tran_params = params['Envelope']['Body']['CancelTransactionArguments']
      transaction = PaynetTransaction.find_by_transaction_id(cancel_tran_params['transactionId'])
      if transaction
        transaction.cancel
        state = transaction.state_status
      end
    rescue Exception => err
      @paynet_status = 102
    ensure
        return envelope('CancelTransactionResult', pack_params(
                                                     errorMsg: STATUS_MESSAGES[@paynet_status],
                                                     status: @paynet_status,
                                                     timeStamp: timestamp.to_s(:w3cdtf),
                                                     transactionState: state))
    end
  end

  def get_statements(date_from, date_to, only_transaction_id)
    transactions = PaynetTransaction.where(created_at: date_from..date_to, state_status: PaynetTransaction::STATUS[:commit]).order(:created_at)
    transactions.map do |t|
      a = {}
      a[:amount] = t.amount unless only_transaction_id
      a[:providerTrnId] = t.id
      a[:transactionId] = t.transaction_id unless only_transaction_id
      a[:transactionTime] = t.created_at.to_s(:w3cdtf) unless only_transaction_id
      '<statements>'+pack_params(a)+'</statements>'
    end.join
  end

  def get_statement
    begin
      paynet_status = 0

      params = Hash.from_xml(request.body.read)
      get_statement_params = params['Envelope']['Body']['GetStatementArguments']
      transactions = get_statements(get_statement_params['dateFrom'], get_statement_params['dateTo'], to_bool(get_statement_params['onlyTransactionId']))
    rescue Exception => err
      paynet_status = 102
      transactions = ''
    ensure
      args = pack_params(errorMsg: STATUS_MESSAGES[paynet_status],
                         status: paynet_status,
                         timeStamp: DateTime.now.to_s(:w3cdtf))
      return envelope('GetStatementResult', args + transactions)
    end
  end
  
  private
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

  def to_bool(text)
    return true if text =~ (/^(true)$/i)
    return false if text =~ (/^(false)$/i)
    raise ArgumentError.new("invalid value for Boolean: \"#{text}\"")
  end
end
