class Warehouse < ActiveRecord::Base
  has_many :inventories
  belongs_to :region
  has_many :transfer_line_items
  has_many :to_transfers, :class_name => 'Transfer', :foreign_key => 'to_warehouse_id'
  has_many :from_transfers, :class_name => 'Transfer', :foreign_key => 'from_warehouse_id'
  
  named_scope :in_central, lambda {|boolean|
    if boolean
      {:conditions => ["warehouses.is_central = 1"]}
    else
      {:conditions => ["warehouses.is_central = 0"]}
    end 
  }
end
