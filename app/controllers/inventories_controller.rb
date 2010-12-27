class InventoriesController < ApplicationController
  before_filter :login_required

  access_control do
    allow :wa
  end

  def index
    if params[:is_central] == "1"
      @inventories = Inventory.in_warehouse(Warehouse.in_central(true).first).paginate(:all,:per_page=>20,:page => params[:page], :order => 'inventories.created_at DESC')
    else
      @inventories = Inventory.in_warehouse(Warehouse.in_central(false).all).paginate(:all,:per_page=>20,:page => params[:page], :order => 'inventories.created_at DESC')
    end
  end

  def calculate_materials
    @material = Material.find(params[:material_id])
    @region = Region.find(params[:region_id])
    i_m_central = Inventory.in_warehouse(Warehouse.in_central(true).first.id).in_material(@material.id).first
    i_m = Inventory.in_warehouse(@region.warehouse.id).in_material(@material.id).first
    total = 0
    order = Order.in_order_status(5).in_region(@region.id).first
    unless order.nil?
      olia = order.order_line_item_adjusteds.in_material(@material.id).first
      total = olia.nil? ? 0 : olia.quantity_total
    end
    render :text => "<br/>#{Warehouse.in_central(true).first.name}总库存量：#{i_m_central.nil? ? 0 : i_m_central.quantity}
                     <br/>#{@region.warehouse.name}当前库存量：#{i_m.nil? ? 0 : i_m.quantity}
                     <br/>最新活动所需数量：#{total}"
  end

end
