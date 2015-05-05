class AddSyncUrlToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :sync_transaction_url, :string
    add_column :providers, :sync_user_url, :string
    add_column :providers, :password, :string
  end
end
