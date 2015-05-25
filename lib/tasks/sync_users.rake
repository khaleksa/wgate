namespace :provider do
  desc "Synchronize providers' users data"
  task sync_users: :environment do
    Provider.all.each do |provider|
      SyncUsersJob.perform_later provider.id if provider.sync_user_url.present?
    end
  end
end
