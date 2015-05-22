class Paynet::ItestsController < Paynet::PaynetsController

  PROVIDER_ID = 3

  def wsdl
    super(PROVIDER_ID)
  end

  def action
    super(PROVIDER_ID)
  end
end
