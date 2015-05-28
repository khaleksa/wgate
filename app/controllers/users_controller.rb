class UsersController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    provider = get_provider
    return render_status 401 unless provider && provider.valid_psw_hash?(params[:password])

    user_data = user_params
    user = User.create do |u|
      u.account = user_data[:id]
      u.first_name = user_data[:name]
      u.last_name = user_data[:family]
      u.provider_id = provider.id
    end
    if user.persisted?
      render_status 200
    else
      render_status 400
    end
  end

  def destroy
    provider = get_provider
    return render_status 401 unless provider

    user = User.where(account: params[:id]).first
    return render_status 404 unless user

    User.destroy(user.id)
    render_status 200
  end

  private
  def user_params
    params.require(:user).permit(:id, :name, :family)
  end

  def get_provider
    Provider.where('name = ?', params[:name]).first
  end
end
