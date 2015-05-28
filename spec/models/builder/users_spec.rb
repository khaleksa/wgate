require 'rails_helper'

describe Builder::Users do
  subject { described_class.new(provider.id) }

  let(:provider_tom) { 'Tom' }
  let(:psw_tom) { 'tom_uz' }
  let!(:provider) { FactoryGirl.create(:provider, name: provider_tom, password: psw_tom, sync_user_url: 'http://example1.com/sync_users') }

  let!(:stubbed_response) do
    fixture = File.read(File.expand_path('fixtures/sync_users_response.json', File.dirname(__FILE__)))

    params = {
        :name => provider.name,
        :password => provider.password,
        :sync_date => provider.sync_user_timestamp
    }.to_json

    stub_request(:get, provider.sync_user_url).
        with(
            query: {
                :name => provider.name,
                :password => Digest::MD5.hexdigest(provider.password),
                :sync_date => provider.sync_user_timestamp
            }
        ).
        to_return(:body => fixture, :status => 200, :headers => { 'Content-Type' => 'text/json' })
  end

  describe '#sync' do
    context 'when added/deleted accounts in response are valid' do
      let!(:user3) { FactoryGirl.create(:user, provider: provider, account: '3333') }
      let!(:user5) { FactoryGirl.create(:user, provider: provider, account: '5555') }

      before { subject.sync }

      it 'creates and deletes users' do
        expect(User.where(provider_id: provider.id).size).to eq(3)
        expect(User.where(provider_id: provider.id).pluck(:account)).to eq(['1111', '2222', '4444'])
      end
    end

    context 'when response accounts for insertion already exist' do
      let!(:user1) { FactoryGirl.create(:user, provider: provider, account: '1111') }
      let!(:user3) { FactoryGirl.create(:user, provider: provider, account: '3333') }
      let!(:user5) { FactoryGirl.create(:user, provider: provider, account: '5555') }

      before { subject.sync }

      it 'creates and deletes users' do
        expect(User.where(provider_id: provider.id).size).to eq(3)
        expect(User.where(provider_id: provider.id).pluck(:account)).to eq(['1111', '2222', '4444'])
      end
    end

    context "when response accounts for deletion don't exist" do
      let!(:user1) { FactoryGirl.create(:user, provider: provider, account: '1111') }

      before { subject.sync }

      it 'creates and deletes users' do
        expect(User.where(provider_id: provider.id).size).to eq(3)
        expect(User.where(provider_id: provider.id).pluck(:account)).to eq(['1111', '2222', '4444'])
      end
    end
  end
end
