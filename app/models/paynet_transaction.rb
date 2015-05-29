class PaynetTransaction < ActiveRecord::Base
  include AASM

  belongs_to :provider
  has_one :payment, as: :paymentable

  validates_presence_of :paynet_id, :amount, :account_id, :provider_id

  after_create :create_payment, :notify_provider

  STATUS_ERROR = 0
  enum status: {
      commited: 1,
      cancelled: 2
  }

  aasm :column => :status, :enum => true do
    state :commited, :initial => true
    state :cancelled

    event :cancel do
      transitions :from => [:commited], :to => :cancelled
      after do
        self.payment.cancel
        self.payment.save!
        notify_provider
      end
    end
  end

  def self.exist?(paynet_transaction_id)
    PaynetTransaction.find_by_paynet_id(paynet_transaction_id).present?
  end

  def notify_provider
    PaymentNotificationJob.perform_later provider.sync_transaction_url, self.payment.json_data
  end

  private
  def create_payment
    payment = self.build_payment do|p|
      p.account_id = self.account_id
      p.amount = self.amount
      p.status = self.status
      p.payment_system = 'paynet'
      p.provider_id = self.provider_id
    end.save!

    notify_provider
  end
end
