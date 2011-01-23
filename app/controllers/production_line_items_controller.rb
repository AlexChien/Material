class ProductionLineItemsController < ApplicationController
  before_filter :login_required
  before_filter :check,:only=>[:update]

  access_control do
    allow :pm,:admin
  end

  def update
    quantity_adjusted = params[:quantity_adjusted].to_i
    quantity_total = @pli.quantity_collected+quantity_adjusted
    if quantity_total < 0
      @error_message = "预定总数不能小于0"
    end
    @pli.update_attributes(:quantity_adjusted=>quantity_adjusted,
                           :quantity_total=>quantity_total) if @error_message.blank?
    render :partial => "productions/production_list"
  end

  def ext_update
    @pli = ProductionLineItem.find(params[:Plis][:id])
    error_message = ""
    return_data = Hash.new()

    quantity_adjusted = params[:Plis][:quantity_adjusted].to_i
    quantity_total = @pli.quantity_collected+quantity_adjusted
    if quantity_total < 0
      error_message = "预定总数不能小于0"
    end

    if @pli.production.locked
      error_message = "生产单已锁定，不能修改"
    end

    if error_message.blank?
      @pli.update_attributes(:quantity_adjusted=>quantity_adjusted,
                             :quantity_total=>quantity_total)
      return_data[:success] = true
      success_message = "物料#{@pli.material.name}数量调整为#{@pli.quantity_adjusted}预定总数为#{@pli.quantity_total}"
      return_data[:message] = success_message
      return_data[:Plis] = {:id=>@pli.id,
                            :sku=>@pli.material.sku,
                            :name=>@pli.material.name,
                            :quantity_collected=>@pli.quantity_collected,
                            :quantity_adjusted=>@pli.quantity_adjusted,
                            :quantity_total=>@pli.quantity_total,
                            :material_id=>@pli.material_id,
                            }
    else
      return_data[:success] = false
      return_data[:message] = error_message
    end
    render :text=>return_data.to_json
  end

protected
  def check
    @production = Production.find(params[:production_id])
    @pli = ProductionLineItem.find(params[:id])
    if @production.locked
      flash[:error] = "生产单已锁定，不能修改"
      redirect_to "/campaigns"
    end
  end

end
