module Paynet

  class PerformTransaction < SoapMethodBase

    def initialize(params)
      @params = params
      @response_status = validate_status
    end

    def build_response
      transaction_id = 0
      timestamp = Time.zone.now
      if @response_status == 0
        transaction = PaynetTransaction.create!(transaction_attributes)
        transaction_id = transaction.id
        timestamp = transaction.created_at
      end
    rescue Exception => err
      @response_status = 102
    ensure
      response_params = {
        errorMsg: STATUS_MESSAGES[@response_status],
        status: @response_status,
        timeStamp: timestamp.to_s(:w3cdtf),
        providerTrnId: transaction_id
      }
      log(transaction_attributes, response_params)
      return envelope('PerformTransactionResult', pack_params(response_params))
    end

    private
    def validate_status
      return 411 if !params_valid? || method_arguments['transactionId'].blank?
      return 412 unless authenticated?
      return 201 if PaynetTransaction.exist?(method_arguments['transactionId'])

      #TODO:: User.exist?
      #unless User.exist?
      #   return 302

      return 0
    end

    def transaction_attributes
     method_params = method_arguments
     {
       account_id: method_params['parameters']['paramValue'].to_i,
       transaction_id: method_params['transactionId'],
       transaction_timestamp: method_params['transactionTime'],
       service_id: method_params['serviceId'].to_i,
       state_status: PaynetTransaction::STATUS[:commit],
       response_status: @response_status,
       response_message: STATUS_MESSAGES[@response_status],
       amount: method_params['amount'].to_i,
       user_name: method_params['username'],
       password: method_params['password']
     }
    end

    def log(tran_attr, response_params)
      data = "#{Time.zone.now} - transaction_attr:#{tran_attr.to_s} response_params:#{response_params.to_s}"
      ::Logger.new("#{Rails.root}/log/paynet_perform_tran_#{Time.zone.now.month}_#{Time.zone.now.year}.log").info(data)
    end
  end

end
