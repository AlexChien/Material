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

  named_scope :in_region, lambda {|region_id|
        {:conditions => ["order_line_item_raws.region_id in (?)", region_id]}
  }

  named_scope :in_material, lambda {|material_id|
        {:conditions => ["order_line_item_raws.material_id in (?)", material_id]}
  }

  def self.raw_total(catalog_id,region_id)
    self.in_catalog(catalog_id).in_region(region_id).first(:select=>"sum(subtotal) as raw_total").raw_total.to_f
  end

  def self.apply_total(catalog_id,region_id)
    self.in_catalog(catalog_id).in_region(region_id).first(:select=>"sum(apply_subtotal) as apply_total").apply_total.to_f
  end

end
