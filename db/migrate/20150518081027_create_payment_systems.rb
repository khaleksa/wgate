class CreatePaymentSystems < ActiveRecord::Migration
  def change
    create_table :payment_systems do |t|
      t.string :name, unique: true
    end
  end
end
