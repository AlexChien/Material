class Warehouse < ActiveRecord::Base
  has_many :inventories
  belongs_to :region
  has_many :transfer_line_items
end
