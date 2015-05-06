class ProvidersController < ApplicationController

  def transactions
    return render_status 400 if missed_transactions_params?

    provider = Provider.where('name = ? AND password = ?', params[:name], params[:password]).first
    return render_status 401 unless provider

    start_date = parse_date(params[:start_date])
    end_date = parse_date(params[:end_date])
    return render_status 415 unless start_date && end_date

    transactions = Statistics.transaction_for(provider.id, start_date, end_date)
    render json: trancate_transaction_data(transactions)
  end

  private
  def trancate_transaction_data(transactions)
    transactions.map do |t|
      {
          :transaction_id => t['transaction_id'],
          :account => t['account'],
          :status => t['transaction_status'], #todo:: check status of transaction
          :amount => t['amount'],
          :timestamp => t['timestamp']
      }
    end
  end

  def missed_transactions_params?
    mandatory_params = [:name, :password, :start_date, :end_date]
    mandatory_params.detect{ |p| params[p].blank? }
  end
end
