# encoding: UTF-8
require 'rails_helper'

DATE_FORMAT = '%m/%d/%y'

describe PaymentsController do
  describe 'POST #transaction_report' do

    let(:user_tom) { 'Tom' }
    let(:psw_tom) { 'tom_uz' }
    let!(:provider) { FactoryGirl.create(:provider, name: user_tom, password: psw_tom) }

    let!(:transaction_1) { create_paynet_transaction_at(4.days.ago, paynet_id: 111, account_id: '111111', provider_id: provider.id, amount: 1000) }
    let!(:transaction_2) { create_paynet_transaction_at(3.days.ago, paynet_id: 222, account_id: '222222', provider_id: provider.id, amount: 2000) }
    let!(:transaction_3) { create_paynet_transaction_at(1.days.ago, paynet_id: 333, account_id: '222222', provider_id: provider.id, amount: 3000) }

    let(:response_data) { JSON.parse(response.body) }

    def send_valid_request
      get :report, params
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

        response_payment = response_data[0]
        payment = transaction_1.payment
        expect(response_payment['id'].to_i).to eq(payment.id)
        expect(response_payment['amount'].to_d).to eq(payment.amount.to_d)
        expect(response_payment['account_id']).to eq(payment.account_id)
        expect(response_payment['status']).to eq(payment.status)
        expect(response_payment['payment_system']).to eq(payment.payment_system)
      end
    end

  end

end
