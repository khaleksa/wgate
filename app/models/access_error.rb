class AccessError < ActiveRecord::Base
  validates_presence_of :account_id
end
