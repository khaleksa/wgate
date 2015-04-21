module Paynet

  class CheckTransaction < SoapMethodBase

    def initialize(params)
      @params = params
      @response_status = validate_status
    end

    def build_response
      timestamp = Time.zone.now
      transaction = PaynetTransaction.find_by_transaction_id(paynet_transaction_id)
      if transaction
        @response_status = 0
        transaction_id = transaction.id
        transaction_state = transaction.state_status
        state_error_status = 'Success'
        state_error_message = ''
      else
        @response_status = 103
        transaction_id = 0
        transaction_state = PaynetTransaction::STATUS[:error]
        state_error_status = 'Error'
        state_error_message = "Transaction with id=#{paynet_transaction_id} wasn't found."
      end
    rescue Exception => err
      @response_status = 102
      transaction_id = 0
      transaction_state = PaynetTransaction::STATUS[:error]
      state_error_status = 'Error'
      state_error_message = 'Internal error'
    ensure
      response_params = {
        errorMsg: STATUS_MESSAGES[@response_status],
        status: @response_status,
        timeStamp: timestamp.to_s(:w3cdtf),
        providerTrnId: transaction_id,
        transactionState: transaction_state,
        transactionStateErrorStatus: state_error_status,
        transactionStateErrorMsg: state_error_message
      }
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
  end

end
