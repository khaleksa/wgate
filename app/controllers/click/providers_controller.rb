class Click::ProvidersController < Click::BasesController

  #TODO:: tom
  def tom
    provider_id = 1
    set_secret_key(provider_id)
    sync
  end

  def erkatoy
    provider_id = 1
    set_secret_key(provider_id)
    sync
  end
end
