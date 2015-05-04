class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :provider_id, null: false, index: true
      t.string :account, null: false, index: true
      t.timestamps null: false
    end
  end
end
