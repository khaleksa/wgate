class AddProviderIdToTransactions < ActiveRecord::Migration
  def change
    add_column :paynet_transactions, :provider_id, :integer
    add_index :paynet_transactions, :provider_id

    add_column :click_transactions, :provider_id, :integer
    add_index :click_transactions, :provider_id
  end
end
