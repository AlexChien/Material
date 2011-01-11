class AddCountCacheToCategory < ActiveRecord::Migration
  def self.up
    add_column :categories, :materials_count, :integer, :default => 0
  end

  def self.down
    remove_column :categories, :materials_count
  end
end
