class User < ActiveRecord::Base
  belongs_to :provider

  validates_presence_of :account
end
