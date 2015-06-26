class CreateAccessErrors < ActiveRecord::Migration
  def change
    create_table :access_errors do |t|
      t.string :account_id
      t.string :payment_system
      t.integer :provider_id

      t.timestamps null: false
    end
  end
end
