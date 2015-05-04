class CreateProviders < ActiveRecord::Migration
  def change
    create_table :providers do |t|
      t.string :name
      t.json :click_params
      t.json :paynet_params
      t.timestamps null: false
    end
  end
end
