class AddTokenToOffers < ActiveRecord::Migration
  def self.up
    add_column :offers, :token, :text
  end

  def self.down
    remove_column :offers, :token
  end
end
