class RenameColumnsOfPaynetTransactions < ActiveRecord::Migration
  def change
    rename_column :paynet_transactions, :transaction_id, :paynet_id
    rename_column :paynet_transactions, :transaction_timestamp, :paynet_timestamp
    rename_column :paynet_transactions, :state_status, :status
    change_column :paynet_transactions, :account_id, :string
  end
end
