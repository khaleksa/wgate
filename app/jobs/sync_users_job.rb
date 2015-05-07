class SyncUsersJob < ActiveJob::Base
  queue_as :default

  def peform(provider_id)
    binding.pry
    provider = Provider.find(provider_id)
    data = {
        :name => provider.name,
        :password => provider.password,
        :sync_date => provider.sync_user_timestamp
    }.to_json

    sync_timestamp = Time.zone.now
    result = HTTParty.post(provider.sync_user_url, :body => send_data, :headers => { 'Content-Type' => 'application/json' })

    #TODO: update Users table with result data
    # [4] pry(main)> a = ['1', '2', '3', '4']
    # => ["1", "2", "3", "4"]
    # [5] pry(main)> b = ['2', '4', 'sdfsdf']
    # => ["2", "4", "sdfsdf"]
    # [6] pry(main)> a - b
    # => ["1", "3"]
    # [7] pry(main)> b - a
    # => ["sdfsdf"]

    provider.update_attributes(sync_user_timestamp: sync_timestamp)

    logger.info "Provider_id: #{provider.id}, SendData at: #{sync_timestamp}"
  end
end
