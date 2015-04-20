module Paynet

  class TransactionCancel < TransactionBase

    def initialize(params)
      @params = params
      @response_status = validate_status
    end

    def build_response
      timestamp = Time.zone.now
      state = 0
      begin
        if @response_status == 0
          transaction = PaynetTransaction.find_by_transaction_id(method_arguments['transactionId'])
          if transaction
            if (transaction.state_status == PaynetTransaction::STATUS[:commit])
              transaction.cancel
            else
              @response_status = 202
            end
            state = transaction.state_status
          end
        end
      rescue Exception => err
        @response_status = 102
      ensure
        return envelope('CancelTransactionResult', pack_params(
                                                     errorMsg: STATUS_MESSAGES[@response_status],
                                                     status: @response_status,
                                                     timeStamp: timestamp.to_s(:w3cdtf),
                                                     transactionState: state))
      end
    end

    private
    def validate_status
      return 411 if !params_valid? || method_arguments['transactionId'].blank?
      return 412 unless authenticated?
      return 103 unless PaynetTransaction.exist?(method_arguments['transactionId'])

      #TODO:: User.exist?
      #unless User.exist?
      #   return 302

      return 0
    end
  end

end
