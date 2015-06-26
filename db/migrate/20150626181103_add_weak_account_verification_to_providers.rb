class AddWeakAccountVerificationToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :weak_account_verification, :boolean, default: false
  end
end
