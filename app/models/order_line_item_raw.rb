class OrderLineItemRaw < ActiveRecord::Base
  belongs_to :campaign
  belongs_to :catalog
  belongs_to :order
  belongs_to :region
  belongs_to :material
  belongs_to :salesrep
  
  named_scope :in_catalog, lambda {|catalog_id|
        {:conditions => ["order_line_item_raws.catalog_id in (?)", catalog_id]}
  }
  
  named_scope :in_salesrep, lambda {|salesrep_id|
        {:conditions => ["order_line_item_raws.salesrep_id in (?)", salesrep_id]}
  }
  
  named_scope :in_material, lambda {|material_id|
        {:conditions => ["order_line_item_raws.material_id in (?)", material_id]}
  }
  
end
