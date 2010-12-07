class Material < ActiveRecord::Base
  has_many :catalogs_materials
  has_many :catalogs, :through => :catalogs_materials
  has_many :order_line_item_raws
  has_many :order_line_item_adjusteds
  has_many :production_line_items
  has_many :inventories
  has_many :transfer_line_items
end
