class InventoriesController < ApplicationController
  before_filter :login_required
  
  access_control do
    allow :wa
  end
  
  def index
    @inventories = Inventory.in_warehouse(Warehouse.in_central(true).first).paginate(:all,:per_page=>20,:page => params[:page], :order => 'inventories.created_at DESC')
  end
  
end
