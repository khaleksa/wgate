# encoding: utf-8

module Paynet

  class GetStatement < SoapMethodBase

    def initialize(params)
      @params = params
      @response_status = validate_status
    end

    def build_response
      transactions = (@response_status == 0) ? get_statements(date_from, date_to, only_transaction_id?) : ''
    rescue Exception => err
      @response_status = 102
      transactions = ''
    ensure
      args = pack_params(errorMsg: STATUS_MESSAGES[@response_status], status: @response_status, timeStamp: DateTime.now.to_s(:w3cdtf))
      return envelope('GetStatementResult', args + transactions)
    end

    private
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

    def validate_status
      return 411 unless params_valid?
      return 412 unless authenticated?
      return 414 if date_from.blank? || date_to.blank? || date_to < date_from

      return 0
    end

    def date_to
      method_arguments['dateTo']
    end

    def date_from
      method_arguments['dateFrom']
    end

    def only_transaction_id?
      to_bool(method_arguments['onlyTransactionId'])
    end
  end

end
