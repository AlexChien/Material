class ChangeUnitPriceScale < ActiveRecord::Migration
  def self.up
    change_column :materials, :cost, :decimal, :precision => 9, :scale => 3, :default => 0
    change_column :catalogs_materials, :price, :decimal, :precision => 9, :scale => 3, :default => 0
    change_column :order_line_item_raws, :unit_price, :decimal, :precision => 9, :scale => 3, :default => 0
    change_column :order_line_item_adjusteds, :unit_price, :decimal, :precision => 9, :scale => 3, :default => 0
  end

  def self.down
    change_column :materials, :cost, :decimal, :precision => 8, :scale => 2, :default => 0
    change_column :catalogs_materials, :price, :decimal, :precision => 8, :scale => 2, :default => 0
    change_column :order_line_item_raws, :unit_price, :decimal, :precision => 8, :scale => 2, :default => 0
    change_column :order_line_item_adjusteds, :unit_price, :decimal, :precision => 8, :scale => 2, :default => 0
  end
end
