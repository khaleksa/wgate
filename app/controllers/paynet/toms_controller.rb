class Paynet::TomsController < Paynet::PaynetsController

  PROVIDER_ID = 2

  def wsdl
    super(PROVIDER_ID)
  end

  def action
    super(PROVIDER_ID)
  end
end
