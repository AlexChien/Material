class OrderLineItemAdjusted < ActiveRecord::Base
  belongs_to :order
  belongs_to :region
  belongs_to :material
  
  named_scope :in_region, lambda {|region_id|
        {:conditions => ["order_line_item_adjusteds.region_id in (?)", region_id]}
  }

  named_scope :in_material, lambda {|material_id|
        {:conditions => ["order_line_item_adjusteds.material_id in (?)", material_id]}
  }
  
  named_scope :in_order, lambda {|order_id|
        {:conditions => ["order_line_item_adjusteds.order_id in (?)", order_id]}
  }
end
