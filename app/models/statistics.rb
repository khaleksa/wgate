class Statistics

  #TODO: add named params
  def self.transaction_for(provider_id, start_date, end_date)
    sql = ActiveRecord::Base.send(:sanitize_sql_array, ["
            SELECT t.*
            FROM (
            SELECT pt.id AS transaction_id, pt.account_id AS account, pt.amount, pt.updated_at AS timestamp
            FROM paynet_transactions pt
            WHERE (pt.provider_id = ?) AND (pt.updated_at BETWEEN [PARAM_START] AND [PARAM_STOP])
            UNION
            SELECT ct.id AS transaction_id, ct.account_id AS account, ct.amount, ct.updated_at AS timestamp
            FROM click_transactions ct
            WHERE (ct.provider_id = ?)
            ) t
            ORDER BY t.timestamp DESC
      ",
      provider_id,
      provider_id
    ])

    result = PaynetTransaction.find_by_sql(sql)
    # PaynetTransaction.where(provider_id: provider_id).where(updated_at: start_date..end_date).order(:updated_at)
  end
end
