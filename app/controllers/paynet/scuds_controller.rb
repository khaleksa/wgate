class Paynet::ScudsController < Paynet::PaynetsController

  PROVIDER_ID = 4

  def wsdl
    super(PROVIDER_ID)
  end

  def action
    super(PROVIDER_ID)
  end
end
