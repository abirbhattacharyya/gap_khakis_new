class AddExpiryToPayments < ActiveRecord::Migration
  def self.up
    add_column :payments, :expiry, :date
  end

  def self.down
    remove_column :payments, :expiry
  end
end
