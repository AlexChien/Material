class AddSkuAndMinNumToMaterial < ActiveRecord::Migration
  def self.up
    add_column :materials,:sku,:string,:null=>false,:unique=>true
    add_column :materials,:min_num,:integer,:default=>0
    rename_column :materials,:spec,:pack_spec
  end

  def self.down
    remove_column :materials,:sku
    remove_column :materials,:min_num
    rename_column :materials,:pack_spec,:spec
  end
end
