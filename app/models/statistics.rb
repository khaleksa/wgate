class Statistics

  #TODO: status attribute is different in paynet and click transactions
  def self.transaction_for(provider_id, start_date, end_date)
    sql = ActiveRecord::Base.send(:sanitize_sql_array, ["
            SELECT t.*
            FROM (
              SELECT pt.id AS transaction_id, pt.account_id AS account, pt.amount,
                     case
                       when pt.status=1 then 'commit'
                       when pt.status=2 then 'cancelled'
                       else 'error'
                     end as transaction_status,
                     pt.updated_at AS timestamp
              FROM paynet_transactions pt
              WHERE (pt.provider_id = :id) AND (pt.updated_at BETWEEN :start AND :stop)
              UNION
              SELECT ct.id AS transaction_id, ct.account_id AS account, ct.amount,
                     ct.status AS transaction_status,
                     ct.updated_at AS timestamp
              FROM click_transactions ct
              WHERE (ct.provider_id = :id) AND (ct.updated_at BETWEEN :start AND :stop)
            ) t
            ORDER BY t.timestamp
      ",
       id: provider_id,
       start: start_date,
       stop: end_date
    ])

    result = PaynetTransaction.find_by_sql(sql)
    # PaynetTransaction.where(provider_id: provider_id).where(updated_at: start_date..end_date).order(:updated_at)
  end
end
