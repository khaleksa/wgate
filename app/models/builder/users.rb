require 'httparty'

module Builder
  class Users
    attr_accessor :provider

    def initialize(provider_id)
      @provider = Provider.find(provider_id)
    end

    def sync
      params = {
          :name => provider.name,
          :password => provider.password,
          :sync_date => provider.sync_user_timestamp
      }

      sync_timestamp = Time.zone.now
      result = HTTParty.get(provider.sync_user_url, query: params)
      raise RuntimeError, result.parsed_response if result.code >= 400
      create_or_delete(result.parsed_response['data'].to_a)
      provider.update_attributes(sync_user_timestamp: sync_timestamp)
    rescue => e
      Rails.logger.error "Builder::Users#sync has got exception - #{e.message}"
    end

    private
    # Response data format:
    # {
    #     "data": [
    #         {"id": "1111", "status": "deleted"},
    #         {"id": "2222", "status": "added"}
    #     ]
    # }
    def create_or_delete(users)
      insert_accounts = []
      delete_accounts = []
      users.each do |user|
        if user['status'] == 'added'
          insert_accounts<<user['id']
        else
          delete_accounts<<user['id']
        end
      end
      add_users(insert_accounts)
      delete_users(delete_accounts)
    end

    def add_users(accounts)
      exist_accounts = User.where(provider_id: provider.id).pluck(:account)
      accounts = accounts - exist_accounts

      columns = [:provider_id, :account]
      values = []
      accounts.each { |account| values<<[provider.id, account] }
      ::User.import columns, values, validate: true
    end

    def delete_users(accounts)
      User.destroy( User.where(provider_id: provider.id, account: accounts).pluck(:id) )
    end
  end
end
