class CreateBudgets < ActiveRecord::Migration
  def self.up
    create_table :budgets do |t|
      t.integer :campaign_id
      t.integer :region_id
      t.decimal :assigned_budget, :precision => 10, :scale => 3, :default => 0
      t.decimal :used_budget, :precision => 10, :scale => 3, :default => 0
      t.decimal :redeemable_budget, :precision => 10, :scale => 3, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :budgets
  end
end
