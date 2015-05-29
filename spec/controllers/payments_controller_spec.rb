# encoding: UTF-8
require 'rails_helper'

DATE_FORMAT = '%m/%d/%y'

describe PaymentsController do
  describe 'POST #transaction_report' do

    let(:user_tom) { 'Tom' }
    let(:psw_tom) { 'tom_uz' }
    let!(:provider) { FactoryGirl.create(:provider, name: user_tom, password: psw_tom) }

    let!(:transaction_0) { create_paynet_transaction_at(6.days.ago, paynet_id: 444, account_id: '222222', provider_id: provider.id, amount: 4000) }
    let!(:transaction_1) { create_paynet_transaction_at(4.days.ago, paynet_id: 111, account_id: '111111', provider_id: provider.id, amount: 1000) }
    let!(:transaction_2) { create_paynet_transaction_at(3.days.ago, paynet_id: 222, account_id: '222222', provider_id: provider.id, amount: 2000) }
    let!(:transaction_3) { create_paynet_transaction_at(1.days.ago, paynet_id: 333, account_id: '222222', provider_id: provider.id, amount: 3000) }

    let(:params) {{
        name: user_tom,
        password: Digest::MD5.hexdigest(psw_tom),
        start_date: start_date,
        end_date: end_date
    }}

    let(:response_data) { JSON.parse(response.body) }
    let(:payments) { response_data["payments"] }

    def send_valid_request
      get :report, params
    end

    context 'with start and end date' do
      let(:start_date) { 5.days.ago }
      let(:end_date) { 2.days.ago }

      it 'returns valid json response' do
        send_valid_request

        expect(response.status).to eq 200
        expect(response.header['Content-Type']).to include 'application/json'
        expect(response_data).to be_a(Hash)
        expect(response_data.size).to eq(2)

        expect(payments).to be_a(Array)
        expect(payments.size).to eq(2)

        payment = transaction_1.payment
        expect(payments[0]['id'].to_i).to eq(payment.id)
        expect(payments[0]['amount'].to_d).to eq(payment.amount.to_d)
        expect(payments[0]['account_id']).to eq(payment.account_id)
        expect(payments[0]['status']).to eq(payment.status)
        expect(payments[0]['payment_system']).to eq(payment.payment_system)
      end
    end

    context 'with start date' do
      let(:start_date) { 5.days.ago }
      let(:end_date) { '' }

      it 'returns valid json response' do
        send_valid_request

        expect(response.status).to eq 200
        expect(response.header['Content-Type']).to include 'application/json'
        expect(response_data).to be_a(Hash)
        expect(response_data.size).to eq(2)

        expect(payments).to be_a(Array)
        expect(payments.size).to eq(3)
      end
    end

    context 'with end date' do
      let(:start_date) { '' }
      let(:end_date) { 2.days.ago }

      it 'returns valid json response' do
        send_valid_request

        expect(response.status).to eq 200
        expect(response.header['Content-Type']).to include 'application/json'
        expect(response_data).to be_a(Hash)
        expect(response_data.size).to eq(2)

        expect(payments).to be_a(Array)
        expect(payments.size).to eq(3)
      end
    end

    context 'without start and end date' do
      let(:start_date) { '' }
      let(:end_date) { '' }

      it 'returns valid json response' do
        send_valid_request

        expect(response.status).to eq 200
        expect(response.header['Content-Type']).to include 'application/json'
        expect(response_data).to be_a(Hash)
        expect(response_data.size).to eq(2)

        expect(payments).to be_a(Array)
        expect(payments.size).to eq(4)
      end
    end
  end

end
