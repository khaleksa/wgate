class CreatePaynetTransactions < ActiveRecord::Migration
  def change
    create_table :paynet_transactions do |t|
      t.string :transaction_id, null: false
      t.datetime :transaction_timestamp
      t.integer :service_id
      t.integer :state_status, null: false
      t.integer :amount
      t.integer :account_id
      t.string :user_name
      t.string :password
      t.string :ip
      t.integer :response_status
      t.string :response_message
      t.timestamps null: false
    end
  end
end
