class Statistics

  def self.transaction_for(provider_id, start_date, end_date)
    Payment.where(provider_id: provider_id)
           .where(updated_at: start_date..end_date)
           .select(:id, :account_id, :amount, :status, :payment_system)
           .order(:updated_at)
  end
end
