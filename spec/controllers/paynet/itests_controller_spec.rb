# encoding: UTF-8
require 'rails_helper'
require 'savon'

describe Paynet::ItestsController do
  HTTPI.adapter = :rack
  HTTPI::Adapter::Rack.mount 'application', Paysys::Application

  let(:user_tom) { 'itest' }
  let(:psw_tom) { '123456' }
  let!(:provider) { FactoryGirl.create(:provider, id: 3, name: 'itest', password: 'itest_psw',
                                        paynet_params: {user_name: user_tom, password: psw_tom},
                                        weak_account_verification: true) }
  let!(:user_account) { '901234567' }
  let!(:long_user_account) { "+998#{user_account}" }
  let!(:user) { FactoryGirl.create(:user, provider_id: provider.id, account: long_user_account, first_name: 'Bob', last_name: 'John') }

  let(:remote_ip) { '213.230.106.113' }
  let(:client) { Savon::Client.new({ :wsdl => "http://application/paynet/itest/wsdl" }) }

  before do
    allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return(remote_ip)
  end

  describe 'soap method: PerformTransaction' do
    let(:params) do
      {
          password: psw_tom,
          username: user_tom,
          amount: 150000,
          parameters: { paramKey: 'account_id', paramValue: long_user_account },
          serviceId: 1,
          transactionId: 437,
          transactionTime: '2011-04-26T18:07:22'
      }
    end
    let(:response) { client.call(:perform_transaction, message: params) }
    let(:transaction) { PaynetTransaction.first }
    let(:perform_transaction_result) { response.body[:perform_transaction_result] }

    context "when user's account exists" do
      it 'returns valid response' do
        expect(perform_transaction_result[:error_msg]).to eq 'Success.'
        expect(perform_transaction_result[:status].to_i).to eq 0
        expect(perform_transaction_result.include?(:time_stamp)).to be_truthy
        expect(perform_transaction_result.include?(:provider_trn_id)).to be_truthy
      end

      it 'create PaymentTransaction' do
        expect{ response }.to change{ PaynetTransaction.all.size }.from(0).to(1)
        expect(transaction.service_id).to eq(1)
        expect(transaction.commited?).to be_truthy
        expect(transaction.amount).to eq(150000)
        expect(transaction.account_id).to eq(user_account)
        expect(transaction.user_name).to eq(user_tom)
        expect(transaction.password).to eq(psw_tom)
      end
    end

    context "when user's account doesn't exist" do
      let(:params) do
        {
            password: psw_tom,
            username: user_tom,
            amount: 150000,
            parameters: { paramKey: 'account_id', paramValue: '111111' },
            serviceId: 1,
            transactionId: 437,
            transactionTime: '2011-04-26T18:07:22'
        }
      end

      it 'returns invalid response' do
        expect(perform_transaction_result[:error_msg]).to eq 'Client was not found.'
        expect(perform_transaction_result[:status].to_i).to eq 302
      end

      it 'creates AccessError' do
        expect{ response }.to change{ AccessError.all.size }.from(0).to(1)
        error = AccessError.first
        expect(error.payment_system).to eq('paynet')
        expect(error.provider_id).to eq(provider.id)
        expect(error.account_id).to eq('111111')
      end
    end
  end

  # describe 'soap method: CancelTransaction' do
  #   let(:transaction_id) { '123456' }
  #   let!(:transaction) { FactoryGirl.create(:paynet_transaction, paynet_id: transaction_id, account_id: user_account, provider_id: provider.id) }
  #   let(:params) do
  #     {
  #         password: psw_tom,
  #         username: user_tom,
  #         serviceId: 1,
  #         transactionId: transaction_id,
  #         parameters: { paramKey: 'reason', paramValue: 'error' }
  #     }
  #   end
  #   let!(:response) { client.call(:cancel_transaction, message: params) }
  #   let(:cancel_transaction_result) { response.body[:cancel_transaction_result] }
  #
  #   it 'returns valid response' do
  #     expect(cancel_transaction_result[:error_msg]).to eq 'Success.'
  #     expect(cancel_transaction_result[:status].to_i).to eq 0
  #     expect(cancel_transaction_result.include?(:time_stamp)).to be_truthy
  #     expect(cancel_transaction_result[:transaction_state].to_i).to eq(2)
  #   end
  #
  #   it 'cancel Payment Transaction state status' do
  #     transaction.reload
  #     expect(transaction.cancelled?).to be_truthy
  #   end
  # end
  #
  # describe 'soap method: CheckTransaction' do
  #   let(:transaction_id) { '123456' }
  #   let(:status_ok) { 0 }
  #   let(:status_ok_msg) { 'Success.' }
  #   let!(:transaction) { FactoryGirl.create(:paynet_transaction, paynet_id: transaction_id, provider_id: provider.id, response_status: status_ok, response_message: status_ok_msg) }
  #   let(:params) do
  #     {
  #         password: psw_tom,
  #         username: user_tom,
  #         serviceId: 1,
  #         transactionId: transaction_id,
  #         transactionTime: '2011-04-26T18:07:22',
  #         parameters: { paramKey: 'agent_id', paramValue: 2222 } # ???
  #     }
  #   end
  #   let(:response) { client.call(:check_transaction, message: params) }
  #   let(:response_data) { response.body[:check_transaction_result] }
  #
  #   it 'returns valid response' do
  #     expect(response_data[:error_msg]).to eq status_ok_msg
  #     expect(response_data[:status].to_i).to eq status_ok
  #     expect(response_data.include?(:time_stamp)).to be_truthy
  #     expect(response_data[:provider_trn_id].to_i).to eq(transaction.id)
  #     expect(response_data[:transaction_state].to_i).to eq(PaynetTransaction.statuses[transaction.status])
  #     expect(response_data[:transaction_state_error_status].to_i).to eq(0)
  #     expect(response_data.include?(:transaction_state_error_msg)).to be_truthy
  #   end
  # end
  #
  # describe 'soap method: GetStatement' do
  #   let!(:transaction_1) { create_paynet_transaction_at(4.days.ago, paynet_id: 111, account_id: user_account, provider_id: provider.id, amount: 1000) }
  #   let!(:transaction_2) { create_paynet_transaction_at(3.days.ago, paynet_id: 222, account_id: user_account, provider_id: provider.id, amount: 2000) }
  #   let!(:transaction_3) { create_paynet_transaction_at(1.days.ago, paynet_id: 333, account_id: user_account, provider_id: provider.id, amount: 3000) }
  #
  #   let(:params) do
  #     {
  #         password: psw_tom,
  #         username: user_tom,
  #         dateFrom: 5.days.ago.strftime(Paynet::DATE_FORMAT),
  #         dateTo: 2.days.ago.strftime(Paynet::DATE_FORMAT),
  #         serviceId: 1,
  #         onlyTransactionId: false,
  #         parameters: { paramKey: 'reason', paramValue: '' }
  #     }
  #   end
  #   let!(:response) { client.call(:get_statement, message: params) }
  #   let(:response_data) { response.body[:get_statement_result] }
  #
  #   it 'returns valid response' do
  #     expect(response_data[:error_msg]).to eq 'Success.'
  #     expect(response_data[:status].to_i).to eq 0
  #     expect(response_data.include?(:time_stamp)).to be_truthy
  #   end
  #
  #   let(:statements) { response_data[:statements] }
  #   it 'returns transaction data' do
  #     expect(statements.size).to eq(2)
  #     expect(statements[0]).to  eq(
  #                                   :amount           => transaction_1.amount.to_s,
  #                                   :provider_trn_id  => transaction_1.id.to_s,
  #                                   :transaction_id   => transaction_1.paynet_id,
  #                                   :transaction_time => transaction_1.created_at.strftime(Paynet::DATE_FORMAT)
  #                               )
  #   end
  # end
  #
  # describe 'soap method: GetInformation' do
  #   let(:params) do
  #     {
  #         password: psw_tom,
  #         username: user_tom,
  #         parameters: { paramKey: 'account_id', paramValue: user_account },
  #         serviceId: 1
  #     }
  #   end
  #   let!(:response) { client.call(:get_information, message: params) }
  #   let(:response_data) { response.body[:get_information_result] }
  #
  #   it 'returns valid response' do
  #     expect(response_data[:error_msg]).to eq 'Success.'
  #     expect(response_data[:status].to_i).to eq 0
  #     expect(response_data.include?(:time_stamp)).to be_truthy
  #   end
  #
  #   let(:parameters) { response_data[:parameters] }
  #   it 'returns client data' do
  #     expect(parameters).to  eq(
  #                                :param_key   => 'name',
  #                                :param_value => user.full_name
  #                            )
  #   end
  # end
end
