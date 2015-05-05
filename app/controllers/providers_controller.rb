class ProvidersController < ApplicationController

  def transactions
    provider = Provider.where('name = ? AND password = ?', params[:name], params[:password]).first
    return render_status 401 unless provider

    start_date = parse_date(params[:start_date])
    end_date = parse_date(params[:end_date])
    transactions = Statistics.transaction_for(provider.id, start_date, end_date)
    binding.pry
    render json: trancate_transaction_data(transactions)
  end

  private
  def trancate_transaction_data(transactions)
    transactions.map do |t|
      {
          :transaction_id => t.id,
          :account => t.account_id,
          :status => (t.status == 1 ? 'create' : 'cancel'),
          :amount => t.amount,
          :timestamp => t.updated_at
      }
    end
  end
end
