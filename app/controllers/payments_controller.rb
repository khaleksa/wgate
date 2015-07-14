class PaymentsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def report
    return render_status 400 if missed_transactions_params?

    provider = Provider.where('name = ?', params[:name]).first
    return render_status 401 unless provider && provider.valid_psw_hash?(params[:password])

    start_date = parse_date(params[:start_date])
    end_date = parse_date(params[:end_date])
    transactions = Statistics.transaction_for(provider, start_date, end_date)
    response = {
      payments: transactions.to_a,
      timestamp: formated_date(Time.zone.now)
    }
    render json: response
  end

  private
  def missed_transactions_params?
    mandatory_params = [:name, :password]
    mandatory_params.detect{ |p| params[p].blank? }
  end
end
