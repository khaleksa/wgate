class CreatePaynetTransactions < ActiveRecord::Migration
  def change
    create_table :paynet_transactions do |t|
      t.integer :status, null: false
      t.string :message
      t.integer :paynet_status
      t.string :user_name
      t.string :password
      t.integer :account_id
      t.integer :amount
      t.integer :service_number
      t.string :paynet_transaction_id, null: false
      t.datetime :paynet_timestamp
      t.string :ip
      t.timestamps null: false
    end
  end
end
