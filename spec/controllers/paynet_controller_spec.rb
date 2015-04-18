# encoding: UTF-8
require 'rails_helper'
require 'savon'

describe PaynetsController do
  HTTPI.adapter = :rack
  HTTPI::Adapter::Rack.mount 'application', Paysys::Application

  # TODO::
  #  config.render_views
  # controller spec vs request spec

  let(:client) { Savon::Client.new({ :wsdl => "http://application/paynet/wsdl" }) }

  describe 'soap method: PerformTransaction' do
    let(:params) do
      {
        password: 'pwd',
        username: 'user',
        amount: 150000,
        parameters: { paramKey: 'agent_id', paramValue: 2222 },
        serviceId: 1,
        transactionId: 437,
        transactionTime: '2011-04-26T18:07:22'
      }
    end
    let(:response) { client.call(:perform_transaction, message: params) }
    let(:transaction) { PaynetTransaction.first }
    let(:perform_transaction_result) { response.body[:perform_transaction_result] }

    it 'returns valid response' do
      expect(perform_transaction_result[:error_msg]).to eq 'Успешно.'
      expect(perform_transaction_result[:status].to_i).to eq 0
      expect(perform_transaction_result.include?(:time_stamp)).to be_truthy
      expect(perform_transaction_result.include?(:provider_trn_id)).to be_truthy
    end

    it 'create PaymentTransaction' do
      expect{ response }.to change{ PaynetTransaction.all.size }.from(0).to(1)
      expect(transaction.service_id).to eq(1)
      expect(transaction.state_status).to eq(1)
      expect(transaction.amount).to eq(150000)
      expect(transaction.account_id).to eq(2222)
      expect(transaction.user_name).to eq('user')
      expect(transaction.password).to eq('pwd')
    end
  end

  describe 'soap method: CancelTransaction' do
    let(:account) { 123456789 }
    let(:transaction_id) { '123456' }
    let!(:transaction) { FactoryGirl.create(:paynet_transaction, transaction_id: transaction_id, account_id: account) }
    let(:params) do
      {
        password: 'pwd',
        usernamer: 'user',
        serviceId: 1,
        transactionId: transaction_id,
        parameters: { paramKey: 'agent_id', paramValue: account }
      }
    end
    let!(:response) { client.call(:cancel_transaction, message: params) }
    let(:cancel_transaction_result) { response.body[:cancel_transaction_result] }

    it 'returns valid response' do
      expect(cancel_transaction_result[:error_msg]).to eq 'Успешно.'
      expect(cancel_transaction_result[:status].to_i).to eq 0
      expect(cancel_transaction_result.include?(:time_stamp)).to be_truthy
      expect(cancel_transaction_result[:transaction_state].to_i).to eq(2)
    end

    it 'cancel Payment Transaction state status' do
      transaction.reload
      expect(transaction.state_status).to eq(2)
    end
  end

  describe 'soap method: CheckTransaction' do
    let(:transaction_id) { '123456' }
    let(:status_ok) { 0 }
    let(:status_ok_msg) { 'Успешно.' }
    let!(:transaction) { FactoryGirl.create(:paynet_transaction, transaction_id: transaction_id, state_status: 1, response_status: status_ok, response_message: status_ok_msg) }
    let(:params) do
      {
        password: 'pwd',
        username: 'user',
        serviceId: 1,
        transactionId: transaction_id,
        transactionTime: '2011-04-26T18:07:22',
        parameters: { paramKey: 'agent_id', paramValue: 2222 } # ???
      }
    end
    let(:response) { client.call(:check_transaction, message: params) }
    let(:response_data) { response.body[:check_transaction_result] }

    it 'returns valid response' do
      expect(response_data[:error_msg]).to eq status_ok_msg
      expect(response_data[:status].to_i).to eq status_ok
      expect(response_data.include?(:time_stamp)).to be_truthy
      expect(response_data[:provider_trn_id].to_i).to eq(transaction.id)
      expect(response_data[:transaction_state].to_i).to eq(1)
      expect(response_data[:transaction_state_error_status].to_i).to eq(status_ok)
      expect(response_data[:transaction_state_error_msg]).to eq(status_ok_msg)
    end
  end
end
