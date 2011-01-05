class AddUsedRedeemableBudgetToRegion < ActiveRecord::Migration
  def self.up
    add_column :regions, :used_budget, :decimal, :precision => 8, :scale => 2, :default => 0
    add_column :regions, :redeemable_budget, :decimal, :precision => 8, :scale => 2, :default => 0
  end

  def self.down
    remove_column :regions, :used_budget
    remove_column :regions, :redeemable_budget
  end
end
