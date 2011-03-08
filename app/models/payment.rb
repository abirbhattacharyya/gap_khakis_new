class Payment < ActiveRecord::Base
  belongs_to :offer
  belongs_to :promotion_code

  validates_format_of :email, :if => :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
end
