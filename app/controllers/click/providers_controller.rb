class Click::ProvidersController < Click::BasesController

  def erkatoy
    provider_id = 1
    set_secret_key(provider_id)
    sync
  end

  def tom
    provider_id = 2
    set_secret_key(provider_id)
    sync
  end

  def itest
    provider_id = 3
    set_secret_key(provider_id)
    sync
  end
end
