class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.references :paymentable, polymorphic: true, index: true
      t.string :payment_system
      t.string :account_id
      t.float :amount
      t.string :status
      t.timestamps null: false
    end
  end
end
