class ChangeIndexInUsers < ActiveRecord::Migration
  def change
    remove_index :users, :account
    add_index(:users, [:account, :provider_id], unique: true)
  end
end
