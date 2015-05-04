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
end
