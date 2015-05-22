class User < ActiveRecord::Base
  belongs_to :provider

  validates_presence_of :account

  def full_name
    "#{last_name} #{first_name}"
  end
end
