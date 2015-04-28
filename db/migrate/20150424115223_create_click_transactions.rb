class CreateClickTransactions < ActiveRecord::Migration
  def change
    create_table :click_transactions do |t|
      t.integer :click_id
      t.string :status
      t.integer :service_id
      t.string :account_id
      t.float :amount
      t.integer :action
      t.integer :click_error
      t.integer :click_error_note
      t.datetime :click_timestamp
      t.string :sign_hash

      t.timestamps null: false
    end
  end
end
