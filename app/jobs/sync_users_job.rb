class SyncUsersJob < ActiveJob::Base
  queue_as :default

  def perform(provider_id)
    Builder::Users.new(provider_id).sync
  end
end
