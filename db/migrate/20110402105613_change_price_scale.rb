class ChangePriceScale < ActiveRecord::Migration
  def self.up
    change_column :order_line_item_adjusteds, :subtotal, :decimal, :precision => 9, :scale => 3, :default => 0
    change_column :order_line_item_applies, :apply_subtotal, :decimal, :precision => 9, :scale => 3, :default => 0
    change_column :order_line_item_raws, :subtotal, :decimal, :precision => 9, :scale => 3, :default => 0
    change_column :orders, :amount, :decimal, :precision => 9, :scale => 3, :default => 0
    change_column :regions, :assigned_budget, :decimal, :precision => 9, :scale => 3, :default => 0
    change_column :regions, :used_budget, :decimal, :precision => 9, :scale => 3, :default => 0
    change_column :regions, :redeemable_budget, :decimal, :precision => 9, :scale => 3, :default => 0
    change_column :transfer_line_items, :unit_price, :decimal, :precision => 9, :scale => 3, :default => 0
    change_column :transfer_line_items, :subtotal, :decimal, :precision => 9, :scale => 3, :default => 0
    change_column :transfers, :amount, :decimal, :precision => 9, :scale => 3, :default => 0
  end

  def self.down
    change_column :order_line_item_adjusteds, :subtotal, :decimal, :precision => 8, :scale => 2, :default => 0
    change_column :order_line_item_applies, :apply_subtotal, :decimal, :precision => 8, :scale => 2, :default => 0
    change_column :order_line_item_raws, :subtotal, :decimal, :precision => 8, :scale => 2, :default => 0
    change_column :orders, :amount, :decimal, :precision => 8, :scale => 2, :default => 0
    change_column :regions, :assigned_budget, :decimal, :precision => 8, :scale => 2, :default => 0
    change_column :regions, :used_budget, :decimal, :precision => 8, :scale => 2, :default => 0
    change_column :regions, :redeemable_budget, :decimal, :precision => 8, :scale => 2, :default => 0
    change_column :transfer_line_items, :unit_price, :decimal, :precision => 8, :scale => 2, :default => 0
    change_column :transfer_line_items, :subtotal, :decimal, :precision => 8, :scale => 2, :default => 0
    change_column :transfers, :amount, :decimal, :precision => 8, :scale => 2, :default => 0
  end
end
