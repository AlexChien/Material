class Campaign < ActiveRecord::Base
  has_many :catalogs
  has_many :orders
  has_many :productions

  accepts_nested_attributes_for :catalogs

  validates_presence_of :name

  named_scope :in_state, lambda {|state|
        {:conditions => ["campaigns.state = ?", state]}
  }

  state_machine :initial => :activated do
    event :delete_campaign  do transition all => :deleted end
  end

  # 使用before_save时，修改catalog属性不生效
  before_create :create_catalog_name_memo
  after_update :update_catalog_name_memo

  def catalog_startdate
    self.catalogs.first.order_startdate.to_date
  end

  def catalog_enddate
    self.catalogs.first.order_enddate.to_date
  end

  def catalogs_list
    list = ""
    cms.each do |cm|
      list += "#{cm.material.name}（内部采购价：#{cm.price}）<br/>"
    end
    list
  end
  
  def campaign_status
    if Date.today < catalog_startdate
      0#未开始
    elsif Date.today >= catalog_startdate && Date.today <= catalog_enddate
      1#进行中
    else
      2#已结束
    end
  end
  
  def show_status
    status = campaign_status
    if campaign_status == 0
      "<font color='yellow'>未开始</font>"
    elsif campaign_status == 1
      "<font color='green'>进行中</font>"
    else
      "<font color='red'>已结束</font>"
    end
  end
  
  def cms
    self.catalogs.first.catalogs_materials
  end

protected

  def create_catalog_name_memo
    catalog_name = self.name + " - 物料目录"
    catalog_description = self.description
    self.catalogs.each do |catalog|
      catalog.name = catalog_name
      catalog.memo = catalog_description
    end
  end

  def update_catalog_name_memo
    self.catalogs.each do |catalog|
      catalog_name = self.name + " - 物料目录"
      catalog_description = self.description
      catalog.update_attributes(:name=>catalog_name,:memo=>catalog_description)
    end
  end

end
