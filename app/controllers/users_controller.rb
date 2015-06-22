class UsersController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    provider = get_provider
    unless provider && provider.valid_psw_hash?(params[:password])
      logger.error "UsersController::#create: Authorization failed\n params = #{params}"
      return render_status 401
    end

    user_data = user_params
    user = User.create do |u|
      u.account = user_data[:id]
      u.first_name = user_data[:name]
      u.last_name = user_data[:family]
      u.provider_id = provider.id
    end
    if user.persisted?
      logger.info "UsersController::#create: provider=#{provider.name}\n provider_data=#{user_data}"
      render_status 200
    else
      logger.error "UsersController::#create: provider=#{provider.name}\n provider_data=#{user_data}"
      render_status 400
    end
  end

  def destroy
    provider = get_provider
    unless provider && provider.valid_psw_hash?(params[:password])
      logger.error "UsersController::#destroy: Authorization failed\n params = #{params}"
      return render_status 401
    end

    user = User.where(account: params[:id]).where(provider_id: provider.id).first
    unless user
      logger.error "UsersController::#destroy: User wasn't found\n params = #{params}"
      return render_status 404
    end

    User.destroy(user.id)
    logger.info "UsersController::#destroy: provider=#{provider.name}\n params = #{params}"
    render_status 200
  rescue => e
    logger.error "UsersController#destroy: #{e.message},\n params = #{params}"
  end

  private
  def user_params
    params.require(:user).permit(:id, :name, :family)
  end

  def get_provider
    Provider.where('name = ?', params[:name]).first
  end

  def logger
    log_path = Rails.env.production? ? '/var/www/paysys/log' : "#{Rails.root}/log"
    @log_file = "#{log_path}/sync_users.log"
    File.new(@log_file, 'w') unless File.exist?(@log_file)

    ::Logger.new(@log_file)
  end
end
