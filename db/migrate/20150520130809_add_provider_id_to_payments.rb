class AddProviderIdToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :provider_id, :integer
    add_index :payments, :provider_id
  end
end
