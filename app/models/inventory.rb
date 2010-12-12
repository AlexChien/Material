class Inventory < ActiveRecord::Base
  belongs_to :material
  belongs_to :region
  belongs_to :warehouse
end
