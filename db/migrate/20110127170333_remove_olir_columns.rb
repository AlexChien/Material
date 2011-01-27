class RemoveOlirColumns < ActiveRecord::Migration
  def self.up
    remove_column :order_line_item_raws, :apply_adjust
    remove_column :order_line_item_raws, :apply_quantity
    remove_column :order_line_item_raws, :apply_subtotal
    remove_column :order_line_item_raws, :address
    remove_column :order_line_item_raws, :memo
  end

  def self.down
    add_column :order_line_item_raws, :apply_adjust, :integer, :default => 0
    add_column :order_line_item_raws, :apply_quantity, :integer, :default => 0
    add_column :order_line_item_raws, :apply_adjust, :precision => 8, :scale => 2, :default => 0
    add_column :order_line_item_raws, :apply_quantity, :string
    add_column :order_line_item_raws, :apply_quantity, :string
  end
end
