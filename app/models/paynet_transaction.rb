class PaynetTransaction < ActiveRecord::Base
  belongs_to :provider

  validates_presence_of :paynet_id, :amount, :account_id, :provider_id

  STATUS = {
    :error => 0,
    :commit => 1,
    :cancelled => 2
  }

  def cancel
    self.status = STATUS[:cancelled]
    self.save!
  end

  def self.exist?(paynet_transaction_id)
    PaynetTransaction.find_by_paynet_id(paynet_transaction_id).present?
  end
end
