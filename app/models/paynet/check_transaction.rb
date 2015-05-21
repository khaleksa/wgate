module Paynet

  class CheckTransaction < SoapMethodBase

    def build_response
      timestamp = Time.zone.now
      transaction = PaynetTransaction.find_by_paynet_id(paynet_transaction_id)
      if transaction
        @response_status = 0
        transaction_id = transaction.id
        transaction_state = PaynetTransaction.statuses[transaction.status]
        state_error_status = transaction.response_status
        state_error_message = ''
      else
        @response_status = 103
        transaction_id = 0
        transaction_state = PaynetTransaction::STATUS_ERROR
        state_error_message = "Transaction with id=#{paynet_transaction_id} wasn't found."
      end
    rescue => exception
      log("CheckTransaction#build_response Error: #{exception.message}")
      @response_status = 102
      transaction_id = 0
      transaction_state = PaynetTransaction::STATUS_ERROR
      state_error_message = 'Internal error'
    ensure
      response_params = {
        errorMsg: STATUS_MESSAGES[@response_status],
        status: @response_status,
        timeStamp: timestamp.strftime(DATE_FORMAT),
        providerTrnId: transaction_id,
        transactionState: transaction_state,
        transactionStateErrorStatus: state_error_status || @response_status,
        transactionStateErrorMsg: state_error_message
      }
      log_params(paynet_transaction_id, response_params)
      return envelope('CheckTransactionResult', pack_params(response_params))
    end

    private
    def validate_status
      return 411 if !params_valid? || method_arguments['transactionId'].blank?
      return 412 unless authenticated?

      return 0
    end

    def paynet_transaction_id
      method_arguments['transactionId']
    end

    def log_params(tran_id, response_params)
      data = "#{Time.zone.now} - paynet_id:#{tran_id.to_s} response_params:#{response_params.to_s}"
      log(data)
    end
  end

end
