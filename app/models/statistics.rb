class Statistics

  #TODO: refactoring
  def self.transaction_for(provider_id, start_date, end_date)
    if start_date && end_date
      Payment.where(provider_id: provider_id)
             .where(updated_at: start_date..end_date)
             .select(:id, :account_id, :amount, :status, :payment_system)
             .order(:updated_at)
    elsif start_date.blank? && end_date
      Payment.where(provider_id: provider_id)
          .where('updated_at <= ?', end_date)
          .select(:id, :account_id, :amount, :status, :payment_system)
          .order(:updated_at)
    elsif start_date && end_date.blank?
      Payment.where(provider_id: provider_id)
          .where('updated_at >= ?', start_date)
          .select(:id, :account_id, :amount, :status, :payment_system)
          .order(:updated_at)
    else
      Payment.where(provider_id: provider_id)
          .select(:id, :account_id, :amount, :status, :payment_system)
          .order(:updated_at)
    end
  end
end
