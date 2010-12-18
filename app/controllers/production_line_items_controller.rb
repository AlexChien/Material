class ProductionLineItemsController < ApplicationController
  before_filter :login_required
  before_filter :check

  access_control do
    allow :pm
  end
  
  def update
    quantity_adjusted = params[:quantity_adjusted].to_i
    quantity_total = @oli.quantity_collected+quantity_adjusted
    if quantity_total < 0
      @error_message = "预定总数不能小于0"
    end
    @oli.update_attributes(:quantity_adjusted=>quantity_adjusted,
                           :quantity_total=>quantity_total) if @error_message.blank?
    render :partial => "productions/production_list"
  end
  
protected
  def check
    @production = Production.find(params[:production_id])
    @oli = ProductionLineItem.find(params[:id])
    if @production.locked
      flash[:error] = "生产单已锁定，不能修改"
      redirect_to "/campaigns"
    end
  end
    
end
