class Click::ProvidersController < Click::BasesController

  def tom
    provider_id = 1
    set_secret_key(provider_id)
    sync
  end
end
