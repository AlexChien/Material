class Region < ActiveRecord::Base
  has_many :users
  has_many :salesreps
  has_many :orders
  has_many :order_line_item_raws
  has_many :order_line_item_adjusteds
  has_many :inventories
  has_one :warehouse
  has_many :transfer_line_items
  
  validates_numericality_of :assigned_budget,:greater_than_or_equal_to=>0
end
