class Catalog < ActiveRecord::Base
  belongs_to :campaign
  has_many :catalogs_materials
  has_many :materials, :through => :catalogs_materials
  has_many :orders
  has_many :productions
  
  validates_presence_of :order_startdate,:order_enddate
  validate :date_check,:order_startdate
  
protected
  def date_check
    if !self.order_startdate.nil? and !self.order_enddate.nil?
      if self.order_startdate > self.order_enddate
        errors.add(:order_startdate, '预定开始时间不能小于预定结束时间！')
      end
    end
  end
  
end
