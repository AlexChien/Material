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
  
  before_save :call_catalog
  
protected

  def call_catalog
    catalog_name = self.name + " - 物料目录"
    catalog_description = self.description
    self.catalogs.each do |catalog|
      catalog.name = catalog_name
      catalog.memo = catalog_description
    end
  end

end
