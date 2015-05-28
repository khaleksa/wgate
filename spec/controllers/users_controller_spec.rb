# encoding: UTF-8
require 'rails_helper'

describe UsersController do
  let(:provider_name) { 'itest' }
  let(:provider_psw) { '123' }
  let!(:provider) { FactoryGirl.create(:provider, id: 3, name: provider_name, password: provider_psw) }
  let(:account) { '12345' }

  describe 'POST users' do
    let(:name) { 'Bob' }
    let(:family) { 'Jones' }
    let(:params) {{
      name: provider_name,
      password: Digest::MD5.hexdigest(provider_psw),
      user: {
          id: account,
          name: name,
          family: family
      }
    }}

    before do
      post :create, params
    end

    it 'has a 200 status code' do
      expect(response.status).to eq(200)
    end

    it 'creates user' do
      user = User.first
      expect(user.account).to eq(account)
      expect(user.first_name).to eq(name)
      expect(user.last_name).to eq(family)
    end
  end

  describe 'DELETE user' do
    let!(:user) { FactoryGirl.create(:user, provider_id: provider.id, account: account) }
    let(:params) {{
        id: account,
        name: provider_name,
        password: provider_psw
    }}

    before do
      delete :destroy, params
    end

    it 'has a 200 status code' do
      expect(response.status).to eq(200)
    end

    it 'delete user' do
      expect(User.all.size).to eq(0)
    end
  end
end
