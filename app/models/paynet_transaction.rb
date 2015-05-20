class PaynetTransaction < ActiveRecord::Base
  belongs_to :provider
  has_one :payment, as: :paymentable

  validates_presence_of :paynet_id, :amount, :account_id, :provider_id

  #TODO: add AASM
  STATUS = {
    :error => 0,
    :commit => 1,
    :cancelled => 2
  }

  after_create :notify_provider

  def cancel
    self.status = STATUS[:cancelled]
    self.save!
    notify_provider
  end

  def self.exist?(paynet_transaction_id)
    PaynetTransaction.find_by_paynet_id(paynet_transaction_id).present?
  end

  def notify_provider
    return if self.status == STATUS[:error]
    TransactionNotificationJob.perform_later provider.sync_transaction_url, sync_json_data
  end

  def sync_json_data
    {
        :transaction_id => self.id,
        :account => self.account_id,
        :status => (status == 1 ? 'create' : 'cancel'),
        :amount => self.amount,
        :timestamp => self.updated_at
    }.to_json
  end
end
