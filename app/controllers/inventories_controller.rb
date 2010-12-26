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
    i_m = Inventory.in_warehouse(Warehouse.in_central(true).first).in_material(@material.id).first
    render :text => "（中央仓库库存量：#{i_m.nil? ? 0 : i_m.quantity}）"
  end

end
