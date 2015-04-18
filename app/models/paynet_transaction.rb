class PaynetTransaction < ActiveRecord::Base
  STATUS = {
      :error => 0,
      :commit => 1,
      :cancelled => 2
  }

  #TODO: add state_machine

  def cancel
    self.state_status = STATUS[:cancelled]
    self.save!
  end
end
