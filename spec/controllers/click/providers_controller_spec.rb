# encoding: UTF-8
require 'rails_helper'

describe Click::ProvidersController do
  let(:secret_key) { 'tom_secret_key' }
  let!(:provider) { FactoryGirl.create(:provider, name: 'tom', password: '123', click_params: {secret_key: secret_key}) }
  let!(:user) { FactoryGirl.create(:user, provider_id: provider.id, account: account_id) }

  let(:click_trans_id) { 123 }
  let(:click_paydoc_id) { 456 }
  let(:account_id) { '123456asd' }
  let(:service_id) { 1 }
  let(:amount) { 1200.50 }
  let(:timestamp) { '2015-04-28 12:13:25' }

  let(:sync_params) { hash_to_param_string(params) }
  let(:sync_request) { post :tom, sync_params, 'CONTENT_TYPE' => 'application/text' }
  let(:response_data) { JSON.parse(response.body) }

  def hash_to_param_string(hash)
    hash.inject('') do |text, (key, value)|
      text = text + '&' if text.present?
      text = text + "#{key}=#{value || ''}"
    end
  end

  describe 'Prepare action' do
    context 'with valid response' do
      let(:action) { 0 }
      let(:sign_string) { Digest::MD5.hexdigest(click_trans_id.to_s + service_id.to_s + secret_key + account_id + amount.to_s + action.to_s + timestamp) }

      let(:params) {{
          click_trans_id: click_trans_id,
          click_paydoc_id: click_paydoc_id,
          service_id: service_id,
          merchant_trans_id: account_id,
          amount: amount,
          action: action,
          error: 0,
          error_note: '',
          sign_time: timestamp,
          sign_string: sign_string
      }}

      it 'returns valid json response' do
        sync_request
        expect(response.header['Content-Type']).to include 'application/json'
        expect(response_data).to be_a(Hash)
        expect(response_data.include?('click_trans_id')).to be_truthy
        expect(response_data.include?('merchant_trans_id')).to be_truthy
        expect(response_data.include?('merchant_prepare_id')).to be_truthy
        expect(response_data['error']).to eq(0)
        expect(response_data.include?('error_note')).to be_truthy
      end

      it 'creates pending ClickTransaction' do
        expect{sync_request}.to change{ ClickTransaction.all.size }.from(0).to(1)
        transaction = ClickTransaction.first
        expect(transaction.status).to eq('pending')
        expect(transaction.click_id).to eq(click_trans_id)
        expect(transaction.service_id).to eq(service_id)
        expect(transaction.account_id).to eq(account_id)
        expect(transaction.amount).to eq(amount)
        expect(transaction.action).to eq(action)
        expect(transaction.click_error).to eq(0)
      end
    end
  end

  describe 'Complete action' do
    context 'with valid response' do
      let(:action) { 1 }
      let(:transaction) { FactoryGirl.create(:click_transaction, click_id: click_trans_id,
                                                                 service_id: service_id,
                                                                 account_id: account_id,
                                                                 amount: amount,
                                                                 action: 0,
                                                                 click_error: 0) }
      let(:sign_string) { Digest::MD5.hexdigest(click_trans_id.to_s + service_id.to_s + secret_key + account_id + transaction.id.to_s + amount.to_s + action.to_s + timestamp) }
      let(:params) {{
          click_trans_id: click_trans_id,
          click_paydoc_id: click_paydoc_id,
          service_id: service_id,
          merchant_trans_id: account_id,
          merchant_prepare_id: transaction.id,
          amount: amount,
          action: action,
          error: 0,
          error_note: '',
          sign_time: timestamp,
          sign_string: sign_string
      }}

      it 'returns valid json response' do
        sync_request
        expect(response.header['Content-Type']).to include 'application/json'
        expect(response_data).to be_a(Hash)
        expect(response_data.include?('click_trans_id')).to be_truthy
        expect(response_data.include?('merchant_trans_id')).to be_truthy
        expect(response_data.include?('merchant_confirm_id')).to be_truthy
        expect(response_data['error']).to eq(0)
        expect(response_data.include?('error_note')).to be_truthy
      end

      it 'changes status of ClickTransaction from pending to commited' do
        expect(transaction.status).to eq('pending')
        sync_request
        transaction.reload
        expect(transaction.status).to eq('commited')
      end
    end
  end
end
