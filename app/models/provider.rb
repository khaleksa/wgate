class Provider < ActiveRecord::Base
  has_many :users
  has_many :paynet_transactions
  has_many :click_transactions

  validates_presence_of :name, :password
  validates_uniqueness_of :name

  def find_user_by(account)
    self.users.where('users.account=?', account).first
  end
end
