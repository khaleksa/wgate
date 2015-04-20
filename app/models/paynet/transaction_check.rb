module Paynet

  class TransactionCheck < TransactionBase

    def initialize(params)
      @params = params
      @response_status = validate_status
    end

    def build_response
      timestamp = Time.zone.now

      begin
        transaction = PaynetTransaction.find_by_transaction_id(paynet_transaction_id)
        if transaction
          @response_status = 0
          transaction_id = transaction.id
          transaction_state = transaction.state_status
          state_error_status = transaction.response_status
          state_error_message = transaction.response_message
        else
          #TODO ??? check values of params
          @response_status = 103
          transaction_id = 0
          transaction_state = 0
          state_error_status = 0
          state_error_message = ''
        end
      rescue Exception => err
        @response_status = 102
        transaction_id = 0
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
