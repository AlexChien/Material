class AddAdjustedSizeToOrderLineItemRaw < ActiveRecord::Migration
  def self.up
    add_column :order_line_item_raws,:adjusted_size,:integer,:default=>0
  end

  def self.down
    remove_column :order_line_item_raws,:adjusted_size
  end
end
