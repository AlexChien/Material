class Region < ActiveRecord::Base
  has_many :users
  has_many :salesreps
  has_many :orders
  has_many :order_line_item_raws
  has_many :order_line_item_adjusteds
  has_many :inventories
  has_one :warehouse
  has_many :transfer_line_items
  has_many :to_transfers, :class_name => 'Transfer', :foreign_key => 'to_region_id'
  has_many :from_transfers, :class_name => 'Transfer', :foreign_key => 'from_region_id'
  
  validates_numericality_of :assigned_budget,:greater_than_or_equal_to=>0
  
  named_scope :in_central, lambda {|boolean|
    if boolean
      {:conditions => ["regions.is_central = 1"]}
    else
      {:conditions => ["regions.is_central = 0"]}
    end 
  }
  
  named_scope :in_id, lambda {|id|
        {:conditions => ["regions.id in (?)", id]}
  }
end
