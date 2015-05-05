class Statistics

  def self.transaction_for(provider_id, start_date, end_date)
    # sql = ActiveRecord::Base.send(:sanitize_sql_array, ["
    #   SELECT pt.id AS transaction_id, pt.account_id AS account, pt.status, pt.amount, pt.updated_at AS timestamp
    #   FROM paynet_transactions pt
    #   WHERE (pt.provider_id = ?) AND (pt.updated_at BETWEEN ? and ?)
    #   ORDER BY pt.updated_at DESC
    #   ",
    #   provider_id,
    #   start_date,
    #   end_date
    # ])
    #
    # PaynetTransaction.find_by_sql(sql)

    PaynetTransaction.where(provider_id: provider_id).where(updated_at: start_date..end_date).order(:updated_at)
  end
end
