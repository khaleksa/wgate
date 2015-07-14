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

    payments = payments.select(:id, :account_id, :amount, :status, :payment_system).order(:updated_at)

    # This bad fix was done for 'itest' provider. 'itest' uses mobile number(12numbers) for account id.
    # '998' is add in the beginning of the account if user input only last 9 numbers of his account
    if provider.weak_account_verification
      payments = payments.map do |payment|
        payment.account_id = '998' + payment.account_id if payment.account_id.to_s.size == 9
        payment
      end
    end

    payments
  end
end
