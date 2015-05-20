class ClickTransaction < ActiveRecord::Base
  include AASM

  belongs_to :provider
  has_one :payment, as: :paymentable

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
      end
    end

    event :commit do
      transitions :from => [:pending], :to => :commited
      after do
        self.payment.commit
        self.payment.save!
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
  def create_payment
    self.build_payment do|p|
      p.account_id = self.account_id
      p.amount = self.amount
      p.status = self.status
      p.payment_system = 'click'
    end.save!
  end
end
