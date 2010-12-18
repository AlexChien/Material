class Order < ActiveRecord::Base
  belongs_to :catalog
  belongs_to :campaign
  belongs_to :region
  belongs_to :order_status
  has_many :order_line_item_raws
  has_many :order_line_item_adjusteds

  named_scope :in_campaign, lambda {|campaign_id|
        {:conditions => ["orders.campaign_id in (?)", campaign_id]}
  }
  
  named_scope :in_catalog, lambda {|catalog_id|
        {:conditions => ["orders.catalog_id in (?)", catalog_id]}
  }

  named_scope :in_region, lambda {|region_id|
        {:conditions => ["orders.region_id in (?)", region_id]}
  }
  
  named_scope :in_order_status, lambda {|order_status_id|
        {:conditions => ["orders.order_status_id in (?)", order_status_id]}
  }

end
