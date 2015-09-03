class Click::ProvidersController < Click::BasesController

  def erkatoy
    set_provider(1)
    sync
  end

  def tom
    set_provider(2)
    sync
  end

  def itest
    set_provider(3)
    sync
  end

  def scud
    set_provider(4)
    sync
  end

end
