class Transfer < ActiveRecord::Base
  has_many :transfer_line_items
  belongs_to :transfer_type
  belongs_to :to_region, :class_name => 'Region'
  belongs_to :from_region, :class_name => 'Region'
  belongs_to :to_warehouse, :class_name => 'Warehouse'
  belongs_to :from_warehouse, :class_name => 'Warehouse'
  
  accepts_nested_attributes_for :transfer_line_items
  
  before_create :observer_transfer_type
  after_create :observer_inventory
  
protected
  
  def observer_transfer_type
    if self.transfer_type_id == 1
      warehouse = Warehouse.in_central(true).first #总仓库
      region = Region.find(5) #市场部
      self.to_region = region
      self.to_warehouse = warehouse
      self.transfer_line_items.each do |tli|
        tli.warehouse = warehouse
        tli.region = region
        tli.subtotal = tli.quantity * tli.unit_price
      end
    end
  end
  
  def observer_inventory
    warehouse = Warehouse.in_central(true).first #总仓库
    region = Region.find(5) #市场部
    self.transfer_line_items.each do |tli|
      @inventory = Inventory.in_region(region).in_warehouse(warehouse).in_material(tli.material).first
      if @inventory
        @inventory.update_attribute(:quantity,@inventory.quantity+tli.quantity)
      else
        Inventory.create(:material=>tli.material,:region=>region,:warehouse=>warehouse,:quantity=>tli.quantity)
      end
    end
  end

end
