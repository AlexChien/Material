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
    amount = 0
    if self.transfer_type_id == 1
      warehouse = Warehouse.in_central(true).first #总仓库
      region = Region.in_central(true).first#Region.find(5) #市场部
      self.to_region = region
      self.to_warehouse = warehouse
      self.transfer_line_items.each do |tli|
        amount += tli.quantity * tli.unit_price
        tli.warehouse = warehouse
        tli.region = region
        tli.subtotal = tli.quantity * tli.unit_price
      end
      self.amount = amount
    elsif self.transfer_type_id == 2 || self.transfer_type_id == 3
      if self.from_warehouse.nil? && self.to_warehouse.nil?
        from_ware_house = Warehouse.find(self.from_region.id)
        if self.transfer_type_id == 2
          to_ware_house = Warehouse.find(self.to_region.id)
        else
          to_ware_house = from_ware_house
        end
        self.from_warehouse = from_ware_house
        self.to_warehouse = to_ware_house
        self.transfer_line_items.each do |tli|
          amount += tli.quantity * tli.unit_price
          tli.warehouse = to_warehouse
          tli.region = self.to_region
          tli.subtotal = tli.quantity * tli.unit_price
        end
        self.amount = amount
      end
    end
  end

  def observer_inventory
    self.transfer_line_items.each do |tli|
      @inventory = Inventory.in_region(tli.region).in_warehouse(tli.warehouse).in_material(tli.material).first
      if @inventory
        @inventory.update_attribute(:quantity,@inventory.quantity+tli.quantity)
      else
        Inventory.create(:material=>tli.material,:region=>tli.region,:warehouse=>tli.warehouse,:quantity=>tli.quantity)
      end
    end
  end

end
