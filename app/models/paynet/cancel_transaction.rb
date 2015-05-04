module Paynet

  class CancelTransaction < SoapMethodBase

    def build_response
      timestamp = Time.zone.now
      state = 0
      begin
        if @response_status == 0
          transaction = PaynetTransaction.find_by_paynet_id(paynet_transaction_id)
          if transaction && can_cancel?(transaction)
            if (transaction.status == PaynetTransaction::STATUS[:commit])
              transaction.cancel
            else
              @response_status = 202
            end
            state = transaction.status
          else
            @response_status = 103
          end
        end
      rescue
        @response_status = 102
      ensure
        response_params = {
          errorMsg: STATUS_MESSAGES[@response_status],
          status: @response_status,
          timeStamp: timestamp.to_s(:w3cdtf),
          transactionState: state
        }
        log(paynet_transaction_id, response_params)
        return envelope('CancelTransactionResult', pack_params(response_params))
      end
    end

    private
    def validate_status
      return 411 if !params_valid? || method_arguments['transactionId'].blank?
      return 412 unless authenticated?
      return 103 unless PaynetTransaction.exist?(method_arguments['transactionId'])

      return 0
    end

    def can_cancel?(transaction)
      edge_time = transaction.created_at.end_of_month - 7.days
      if (transaction.created_at <= edge_time)
        return (Time.zone.now <= (transaction.created_at + 10.days))
      else
        return (Time.zone.now <= (transaction.created_at.end_of_month + 3.days))
      end
    end

    def paynet_transaction_id
      method_arguments['transactionId']
    end

    def log(tran_id, response_params)
      data = "#{Time.zone.now} - paynet_id:#{tran_id.to_s} response_params:#{response_params.to_s}"
      ::Logger.new("#{Rails.root}/log/paynet_#{Time.zone.now.month}_#{Time.zone.now.year}.log").info(data)
    end
  end

end
