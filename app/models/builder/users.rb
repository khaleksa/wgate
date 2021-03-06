require 'httparty'

module Builder
  class Users
    attr_accessor :provider

    def initialize(provider_id)
      @provider = Provider.find(provider_id)
    end

    def sync
      sync_date = provider.sync_user_timestamp.present? ? provider.sync_user_timestamp.strftime('%d-%m-%Y %H:%M') : ''
      params = {
          :name => provider.name,
          :password => provider.password_md5,
          :sync_date => sync_date
      }.to_json

      sync_timestamp = Time.zone.now
      result = HTTParty.post(provider.sync_user_url,
                             body: params,
                             headers: { 'Content-Type' => 'application/json' })

      raise RuntimeError, result.parsed_response if result.code >= 400

      create_or_delete(result.parsed_response.to_a)
      provider.update_attributes(sync_user_timestamp: sync_timestamp)

      logger.info "Builder::Users#sync: provider=#{provider.name} send_sync_date=#{sync_date}\n provider_reponse=#{result.parsed_response}"
    rescue => e
      logger.error "Builder::Users#sync: #{e.message},\n provider_reponse = #{result.parsed_response}"
    end

    private
    def create_or_delete(data)
      insert_users = []
      delete_accounts = []
      data.each do |row|
        if row['status'] == 'added'
          user = {}
          user[:account] = row['id']
          user[:first_name] = row['name']
          user[:last_name] = row['family']
          insert_users<<user
        else
          delete_accounts<<row['id']
        end
      end
      add_users(insert_users)
      delete_users(delete_accounts)
    end

    def add_users(users)
      exist_accounts = User.where(provider_id: provider.id).pluck(:account)

      columns = [:provider_id, :account, :first_name, :last_name]
      values = []
      users.each do |user|
        next if exist_accounts.include?(user[:account])
        values<<[provider.id, user[:account], user[:first_name], user[:last_name]]
      end
      ::User.import columns, values, validate: true
    end

    def delete_users(accounts)
      User.destroy( User.where(provider_id: provider.id, account: accounts).pluck(:id) )
    end

    def logger
      log_path = Rails.env.production? ? '/var/www/paysys/log' : "#{Rails.root}/log"
      @log_file = "#{log_path}/sync_users.log"
      File.new(@log_file, 'w') unless File.exist?(@log_file)

      ::Logger.new(@log_file)
    end
  end
end
