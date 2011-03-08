class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products do |t|
      t.references :user

      t.string :style_num
      t.string :style_description
      t.string :color_description
      t.float :first_cost
      t.float :ticketed_retail
      t.float :margin
      t.float :margin_price
      t.float :selling_price
      t.string :image_url

      t.timestamps
    end
  end

  def self.down
    drop_table :products
  end
end
