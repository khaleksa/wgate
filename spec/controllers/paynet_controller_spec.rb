# encoding: UTF-8
require 'rails_helper'

describe PaynetController do

  describe 'POST #action' do
    before do
      ActionDispatch::Request.any_instance.stub(:remote_ip).and_return(remote_ip)
    end

    def make_valid_request_call
      post :action, email: email, first_name: 'John', last_name: 'Dow', city_id: city_id
    end

    context 'when request comes from unknown ip' do
      let(:remote_ip) { '10.20.30.40' }

      it do
        make_valid_request_call
        should respond_with 403
      end
    end

    context 'when request comes from known ip' do
      let(:remote_ip) { '127.0.0.1' }

      before do
        make_valid_request_call
      end

      context 'and email does not exists' do

        context 'and city exists' do
          it { should respond_with 200 }
          it 'creates new user with city' do
            expect(User.count).to eq 2
            new_user = User.last
            expect(new_user.email).to eq 'new_user@example.com'
            expect(new_user.first_name).to eq 'John'
            expect(new_user.last_name).to eq 'Dow'
            expect(new_user.city.name).to eq 'Москва'
          end
        end

        context 'and city does not exist' do
          let(:city_id) { '1111' }

          it { should respond_with 200 }
          it 'creates new user without city' do
            expect(User.count).to eq 2
            new_user = User.last
            expect(new_user.email).to eq 'new_user@example.com'
            expect(new_user.first_name).to eq 'John'
            expect(new_user.last_name).to eq 'Dow'
            expect(new_user.city).to be_nil
          end
        end

      end

      context 'and email already exists' do
        let(:email) { 'user@example.com' }
        it { should respond_with 400 }
        it('does not create new user') { expect(User.count).to eq 1 }
      end
    end
  end

end
