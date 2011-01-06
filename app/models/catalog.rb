class Catalog < ActiveRecord::Base
  belongs_to :campaign
  has_many :catalogs_materials
  has_many :materials, :through => :catalogs_materials
  has_many :orders
  has_one :production
  has_many :order_line_item_raws

  validates_presence_of :order_startdate,:order_enddate
  validate :start_date_check,:order_startdate
  # validate :end_date_check,:order_enddate

  named_scope :starting, lambda {|boolean|
    if boolean
      {:conditions => ["'#{Date.today}' >= catalogs.order_startdate and '#{Date.today}' <= catalogs.order_enddate"]}
    end
  }

protected
  def start_date_check
    if !self.order_startdate.nil? and !self.order_enddate.nil?
      if self.order_startdate > self.order_enddate
        errors.add(:order_startdate, '预定开始时间不能小于预定结束时间！')
      end
    end
  end

  def end_date_check
    if !self.order_startdate.nil? and !self.order_enddate.nil?
      if Date.today > self.order_enddate.to_date
        errors.add(:order_enddate, '预定结束时间不能小于当前时间！')
      end
    end
  end

end
