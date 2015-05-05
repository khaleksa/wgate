class ClickTransaction < ActiveRecord::Base
  belongs_to :provider

  include AASM

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

  def sync_json_data
    return if self.pending?
    {
        :transaction_id => self.id,
        :amount => self.amount,
        :account => self.account_id,
        :status => (self.commited? ? 'create' : 'cancel')
    }.to_json
  end
end
