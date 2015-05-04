class Paynet::TomsController < Paynet::PaynetsController

  PROVIDER_ID = 1

  def wsdl
    super(PROVIDER_ID)
  end

  def action
    super(PROVIDER_ID)
  end
end
