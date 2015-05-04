FactoryGirl.define do
  factory :paynet_transaction do
    paynet_id 111
    paynet_timestamp 2.days.ago
    service_id 777
    status 1
    amount 1000
    account_id 555
    user_name 'Bob Johns'
    password '111'
    response_status 0
    response_message 'Paynet transaction message'
  end

end
