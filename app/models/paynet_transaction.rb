class PaynetTransaction < ActiveRecord::Base
  STATUS = {
    :commit => 0,
    :error => 1,
    :cancelled => 2
  }

  #TODO: add state_machine

  def cancel
    self.state_status = STATUS[:cancelled]
    self.save!
  end

  def self.exist?(paynet_transaction_id)
    PaynetTransaction.find_by_transaction_id(paynet_transaction_id).present?
  end
end
