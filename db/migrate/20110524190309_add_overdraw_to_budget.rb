class AddOverdrawToBudget < ActiveRecord::Migration
  def self.up
    add_column :budgets, :overdraw, :integer, :default => 0
  end

  def self.down
    remove_column :budgets, :overdraw
  end
end
