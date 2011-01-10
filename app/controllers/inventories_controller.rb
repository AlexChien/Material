class InventoriesController < ApplicationController
  before_filter :login_required

  access_control do
    allow :wa, :pm, :admin, :rc, :rm
  end

  def index
    if current_user.has_role?("wa")
      @inventories = Inventory.in_region(Region.in_central(true).first).paginate(:all,:per_page=>20,:page => params[:page], :order => 'inventories.created_at DESC')
    elsif current_user.has_role?("rc") || current_user.has_role?("rm")
      @inventories = Inventory.in_region(current_user.region).paginate(:all,:per_page=>20,:page => params[:page], :order => 'inventories.created_at DESC')
    elsif current_user.has_role?("pm") || current_user.has_role?("admin")
      if params[:is_central] == "1"
        @inventories = Inventory.in_region(Region.in_central(true).first).paginate(:all,:per_page=>20,:page => params[:page], :order => 'inventories.created_at DESC')
      else
        @inventories = Inventory.in_region(Region.in_central(false).all).paginate(:all,:per_page=>20,:page => params[:page], :order => 'inventories.created_at DESC')
      end
    end
  end

  def calculate_materials
    @material = Material.find(params[:material_id])
    @region = Region.find(params[:region_id])
    i_m_central = Inventory.in_region(Region.in_central(true).first.id).in_material(@material.id).first
    i_m = Inventory.in_region(@region.id).in_material(@material.id).first
    quantity = i_m.nil? ? 0 : i_m.quantity
    total = OrderLineItemAdjusted.in_material(@material.id).is_arrived(0).first(:select=>"sum(quantity_total) as total").total.to_i
    render :text => "<br/>#{Warehouse.in_central(true).first.name}总库存量：#{i_m_central.nil? ? 0 : i_m_central.quantity}
                     <br/>#{@region.warehouse.name}当前库存量：#{quantity}
                     <br/>待转物料数量：#{total-quantity<0 ? 0 : total-quantity}"
  end

end
