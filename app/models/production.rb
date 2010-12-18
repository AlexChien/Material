class Production < ActiveRecord::Base
  has_many :production_line_items
  belongs_to :campaign
  belongs_to :catalog
  
  named_scope :in_catalog, lambda {|catalog_id|
        {:conditions => ["productions.catalog_id in (?)", catalog_id]}
  }

  named_scope :in_campaign, lambda {|campaign_id|
        {:conditions => ["productions.campaign_id in (?)", campaign_id]}
  }
  
  def show_status
    if self.locked
      "已锁定"
    else
      "可修改"
    end
  end
end
