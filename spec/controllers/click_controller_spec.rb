# encoding: UTF-8
require 'rails_helper'

describe ClickController do
  let(:user_tom) { 'TomUz2014' }
  let(:psw_tom) { 'tom10v000317' }
  let(:remote_ip) { '213.230.106.113' }

  # action - int
  # error - int
  # error_note - varchar
  # sign_time - varchar
  # sign_string - varchar

  describe '#sync' do
    let(:click_trans_id) { 123 }
    let(:account_id) { '123456asd' }

    context 'when Prepare action'
    # let(:params) do
    #   {
    #     click_trans_id: click_trans_id,
    #     service_id: 1,
    #     merchant_trans_id: account_id,
    #     amount: 1200.50,
    #     action: 0,
    #     error: 0,
    #     error_note: '',
    #     sign_time: Time.zone.now,
    #     sign_string: 'xxx???'
    #   }
    # end
    #
    # before do
    #   post :sync, params
    # end

    let(:params) do
      {
          action: 1,
          click_trans_id: click_trans_id,
          merchant_trans_id: account_id,
          amount: 1200.50,
      }
    end

    before do
      post :sync, params
    end

    it 'returns valid response' do
      expect(response).to eq 'Успешно.'
    end

  end
end
