class AddAddressToSalesrep < ActiveRecord::Migration
  def self.up
    add_column :salesreps,:address,:string
  end

  def self.down
    remove_column :salesreps,:address
  end
end
