# encoding: UTF-8
require 'rails_helper'

DATE_FORMAT = '%m/%d/%y'

describe ProvidersController do
  describe 'POST #transaction_report' do

    let(:user_tom) { 'Tom' }
    let(:psw_tom) { 'tom_uz' }
    let!(:provider) { FactoryGirl.create(:provider, name: user_tom, password: psw_tom) }

    let(:transaction_status) { PaynetTransaction::STATUS[:commit] }
    let!(:transaction_1) { create_paynet_transaction_at(4.days.ago, paynet_id: 111, account_id: '111111', provider_id: provider.id, status: transaction_status, amount: 1000) }
    let!(:transaction_2) { create_paynet_transaction_at(3.days.ago, paynet_id: 222, account_id: '222222', provider_id: provider.id, status: transaction_status, amount: 2000) }
    let!(:transaction_3) { create_paynet_transaction_at(1.days.ago, paynet_id: 333, account_id: '222222', provider_id: provider.id, status: transaction_status, amount: 3000) }

    let(:response_data) { JSON.parse(response.body) }

    def send_valid_request
      get :transactions, params
    end

    context 'valid request' do
      let(:params) {{
          name: user_tom,
          password: psw_tom,
          start_date: 5.days.ago,
          end_date: 2.days.ago
      }}

      it 'returns valid json response' do
        send_valid_request

        expect(response.status).to eq 200
        expect(response.header['Content-Type']).to include 'application/json'
        expect(response_data).to be_a(Array)
        expect(response_data.size).to eq(2)

        first_tr = response_data[0]
        binding.pry
        expect(first_tr['transaction_id'].to_i).to eq(transaction_1.id)
        expect(first_tr['account']).to eq('111111')
        expect(first_tr['status']).to eq('create')
        # expect(Time.zone.parse(first_tr['timestamp'])).to eq(transaction_1.updated_at)
      end
    end

  end

end
