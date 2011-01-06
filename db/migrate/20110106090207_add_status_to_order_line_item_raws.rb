class AddStatusToOrderLineItemRaws < ActiveRecord::Migration
  def self.up
    add_column :order_line_item_raws,:status,:integer,:default=>0
  end

  def self.down
    remove_column :order_line_item_raws,:status
  end
end
