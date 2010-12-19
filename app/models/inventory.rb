class Inventory < ActiveRecord::Base
  belongs_to :material
  belongs_to :region
  belongs_to :warehouse
  
  named_scope :in_region, lambda {|region_id|
        {:conditions => ["inventories.region_id in (?)", region_id]}
  }
  
  named_scope :in_warehouse, lambda {|warehouse_id|
        {:conditions => ["inventories.warehouse_id in (?)", warehouse_id]}
  }
  
  named_scope :in_material, lambda {|material_id|
        {:conditions => ["inventories.material_id in (?)", material_id]}
  }
end
