# encoding: UTF-8
require 'rails_helper'
require 'savon'

describe PaynetsController do
  HTTPI.adapter = :rack
  HTTPI::Adapter::Rack.mount 'application', Paysys::Application

  it 'can perform transaction' do
    client = Savon::Client.new({:wsdl => "http://application/paynet/wsdl" })
    message = {
        password: 'pwd',
        usernamer: 'user',
        amount: 150000,
        parameters: [],
        serviceId: 1,
        transactionId: 437,
        transactionTime: '2011-04-26T18:07:22'
    }
    binding.pry
    result = client.call(:perform_transaction, message: message)
    binding.pry
    expect(result.body[:perform_transaction_result][:status]).to eq 0
  end
end
