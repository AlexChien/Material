class Catalog < ActiveRecord::Base
  belongs_to :campaign
  has_many :catalogs_materials
  has_many :materials, :through => :catalogs_materials
  has_many :orders
  has_many :productions
end
