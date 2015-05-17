class AddClickPaydocIdToClickTransactions < ActiveRecord::Migration
  def change
    add_column :click_transactions, :click_paydoc_id, :integer
  end
end
