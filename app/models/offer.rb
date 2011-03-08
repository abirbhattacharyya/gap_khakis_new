class Offer < ActiveRecord::Base
  belongs_to :product
  has_one :payment

  named_scope :accepted_offers, {:conditions => ["response LIKE ? OR response LIKE ? OR response LIKE ?", "paid", "accepted", "counter"]}

  def accepted?
    (self.response.eql? "accepted")
  end

  def rejected?
    (self.response.eql? "rejected")
  end

  def paid?
    (self.response.eql? "paid")
  end

  def counter?
    (self.response.eql? "counter")
  end

  def last?
    (self.response.eql? "last")
  end
end
