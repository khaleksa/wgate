class SyncUsersJob < ActiveJob::Base
  queue_as :default

  def perform(provider_id)
    Builder::Users.new(provider_id).sync
    logger.info "Provider_id: #{provider_id}"
  end
end
