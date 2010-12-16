class Order < ActiveRecord::Base
  belongs_to :catalog
  belongs_to :campaign
  belongs_to :region
  has_many :order_statuses
  has_many :order_line_item_raws
  has_many :order_line_item_adjusteds

  named_scope :in_catalog, lambda {|catalog_id|
        {:conditions => ["orders.catalog_id in (?)", catalog_id]}
  }

  named_scope :in_region, lambda {|region_id|
        {:conditions => ["orders.region_id in (?)", region_id]}
  }

end
