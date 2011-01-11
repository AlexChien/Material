class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.string :cid,:null => false
      t.string :name,:null => false
      t.string :state
      t.timestamps
    end

    add_index :categories, :cid, :unique => true

    add_column :materials, :category_id, :integer, :null => false
    add_column :materials, :max_num, :integer, :default => 0

  end

  def self.down
    drop_table :categories

    remove_column :materials, :category_id
    remove_column :materials, :max_num
  end
end
