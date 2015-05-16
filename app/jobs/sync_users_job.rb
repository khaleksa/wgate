class SyncUsersJob < ActiveJob::Base
  queue_as :default

  def peform(provider_id)
    Builder::Users.new(provider_id).sync
    logger.info "Provider_id: #{provider.id}"
  end
end
