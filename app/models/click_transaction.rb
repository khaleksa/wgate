class ClickTransaction < ActiveRecord::Base
  include AASM

  belongs_to :provider
  has_one :payment, as: :paymentable, dependent: :destroy

  validates_presence_of :click_id, :amount, :account_id, :provider_id

  after_create :create_payment

  aasm column: 'status' do
    state :pending, :initial => true
    state :commited
    state :cancelled

    event :cancel do
      transitions :from => [:pending], :to => :cancelled
      after do
        self.payment.cancel
        self.payment.save!
        notify_provider
      end
    end

    event :commit do
      transitions :from => [:pending], :to => :commited
      after do
        self.payment.commit
        self.payment.save!
        notify_provider
      end
    end
  end

  def sync_json_data
    return if self.pending?
    {
        :transaction_id => self.id,
        :amount => self.amount,
        :account => self.account_id,
        :status => (self.commited? ? 'create' : 'cancel')
    }.to_json
  end

  private
  def notify_provider
    PaymentNotificationJob.perform_later provider.id, self.payment.sync_data
  end

  def create_payment
    self.build_payment do|p|
      p.account_id = self.account_id
      p.amount = self.amount
      p.status = self.status
      p.payment_system = 'click'
      p.provider_id = self.provider_id
    end.save!
  end
end
