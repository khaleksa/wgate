module Paynet

  class PerformTransaction < SoapMethodBase

    def build_response
      transaction_id = 0
      timestamp = Time.zone.now
      if @response_status == 0
        transaction = PaynetTransaction.create!(transaction_attributes)
        transaction_id = transaction.id
        timestamp = transaction.created_at
      end
    rescue => exception
      log("PerformTransaction#build_response Error: #{exception.message}")
      @response_status = 102
    ensure
      response_params = {
        errorMsg: STATUS_MESSAGES[@response_status],
        status: @response_status,
        timeStamp: timestamp.strftime(DATE_FORMAT),
        providerTrnId: transaction_id
      }
      log_params(transaction_attributes, response_params)
      return envelope('PerformTransactionResult', pack_params(response_params))
    end

    private
    def validate_status
      return 411 if !params_valid? || method_arguments['transactionId'].blank?
      return 412 unless authenticated?
      return 201 if PaynetTransaction.exist?(method_arguments['transactionId'])

      unless provider.find_user_by_account(user_account)
        AccessError.create(account_id: user_account, payment_system: 'paynet', provider_id: provider.id)
        return 302
      end

      return 0
    end

    def transaction_attributes
      method_params = method_arguments
      {
        account_id: user_account,
        provider_id: provider.id,
        paynet_id: method_params['transactionId'],
        paynet_timestamp: method_params['transactionTime'],
        service_id: method_params['serviceId'].to_i,
        response_status: @response_status,
        response_message: STATUS_MESSAGES[@response_status],
        amount: method_params['amount'].to_i,
        user_name: method_params['username'],
        password: method_params['password']
      }
    end

    def user_account
      account = method_arguments['parameters']['paramValue'].strip
      account = account.gsub(/^[+]/, '') if provider.weak_account_verification
      account
    end

    def log_params(tran_attr, response_params)
      data = "#{Time.zone.now} - transaction_attr:#{tran_attr.to_s} response_params:#{response_params.to_s}"
      log(data)
    end
  end

end
