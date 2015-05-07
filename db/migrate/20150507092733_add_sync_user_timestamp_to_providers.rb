class AddSyncUserTimestampToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :sync_user_timestamp, :datetime
  end
end
