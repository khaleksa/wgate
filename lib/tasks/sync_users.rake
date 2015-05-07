namespace :providers do
  desc "Synchronize providers' users data"
  task sync_users: :environment do
    Providers.all.each do |provider|
      SyncUsersJob.perform_later provider.id
    end
  end
end
