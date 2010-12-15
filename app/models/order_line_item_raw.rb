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
end
