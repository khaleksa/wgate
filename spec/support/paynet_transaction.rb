require 'timecop'

module CreateInPastHelper

  def create_paynet_transaction_at(timestamp, args)
    ::Timecop.travel(timestamp) do
      transaction = PaynetTransaction.new(args)
      transaction if transaction.save!
    end
  end

end
