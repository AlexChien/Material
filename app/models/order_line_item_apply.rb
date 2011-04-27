class OrderLineItemApply < ActiveRecord::Base
  belongs_to :order_line_item_raw
  belongs_to :material
  belongs_to :region
  belongs_to :salesrep

  validates_numericality_of :apply_quantity,:greater_than=>0

  named_scope :in_region, lambda {|region_id|
        {:conditions => ["order_line_item_applies.region_id in (?)", region_id]}
  }

  named_scope :in_status, lambda {|status|
        {:conditions => ["order_line_item_applies.status in (?)", status]}
  }
  
  named_scope :not_in_status, lambda {|status|
        {:conditions => ["order_line_item_applies.status not in (?)", status]}
  }
  
  named_scope :in_material, lambda {|material_id|
        {:conditions => ["order_line_item_applies.material_id in (?)", material_id]}
  }
  
  named_scope :in_salesrep, lambda {|salesrep_id|
        {:conditions => ["order_line_item_applies.salesrep_id in (?)", salesrep_id]}
  }

  def show_status
    if self.status == 1
      "申领已退回"
    elsif self.status == 2
      "申领审批中"
    elsif self.status == 3
      "等待发货"
    elsif self.status == 4
      "等待收货确认"
    elsif self.status == 5
      "确认已收货"
    end
  end

end
