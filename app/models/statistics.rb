class Statistics

  def self.transaction_for(provider, start_date, end_date)
    payments = Payment.where(provider_id: provider.id)

    if start_date && end_date
      payments = payments.where(updated_at: start_date..end_date)
    elsif start_date.blank? && end_date
      payments = payments.where('updated_at <= ?', end_date)
    elsif start_date && end_date.blank?
      payments = payments.where('updated_at >= ?', start_date)
    end

    payments.select(:id, :account_id, :amount, :status, :payment_system).order(:updated_at)

  end
end
