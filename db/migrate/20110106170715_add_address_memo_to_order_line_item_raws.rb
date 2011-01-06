class AddAddressMemoToOrderLineItemRaws < ActiveRecord::Migration
  def self.up
    add_column :order_line_item_raws,:address,:string
    add_column :order_line_item_raws,:memo,:text
  end

  def self.down
    remove_column :order_line_item_raws,:address
    remove_column :order_line_item_raws,:memo
  end
end
