class User < ActiveRecord::Base
  belongs_to :provider

  validates_presence_of :account, :provider_id
  validates_uniqueness_of :account, scope: :provider_id

  def full_name
    "#{last_name} #{first_name}"
  end
end
