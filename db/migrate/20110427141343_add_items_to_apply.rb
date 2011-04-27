class AddItemsToApply < ActiveRecord::Migration
  def self.up
    add_column :order_line_item_applies,:material_id,:integer
    add_column :order_line_item_applies,:region_id,:integer
    add_column :order_line_item_applies,:salesrep_id,:integer
  end

  def self.down
    remove_column :order_line_item_applies,:material_id
    remove_column :order_line_item_applies,:region_id
    remove_column :order_line_item_applies,:salesrep_id
  end
end
