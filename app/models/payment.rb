class Payment < ActiveRecord::Base
  include AASM

  belongs_to :paymentable, polymorphic: true

  validates_presence_of :payment_system, :account_id, :amount, :status

  aasm column: 'status' do
    state :pending, :initial => true
    state :commited
    state :cancelled

    event :cancel do
      transitions :from => [:pending], :to => :cancelled
    end

    event :commit do
      transitions :from => [:pending], :to => :commited
    end
  end
end
