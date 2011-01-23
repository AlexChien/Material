class ProductionsController < ApplicationController
  before_filter :login_required

  access_control do
    allow :pm,:admin
  end

  def show
    @production = Production.find(params[:id])
  end

  def update
    @production = Production.find(params[:id])
    @production.update_attribute(:locked,true)
    flash[:notice] = "生产单已锁定！"
    redirect_to "/productions/#{@production.id}"
  end

  def print
    @production = Production.find(params[:id])
    if @production.locked
      render :layout => "print"
    else
      render :text => "该生产单不能打印"
    end
  end

  def load_data
    @production = Production.find(params[:id])
    # params[:filter].each do |index,f|
    #   puts params[:filter][index.to_s]["field"]
    #   puts params[:filter][index.to_s]["data"]["value"]
    # end
    @plis = @production.production_line_items.all(:include=>[:material])
    return_data = Hash.new()
    return_data[:size] = @plis.size
    return_data[:Plis] = @plis.collect{|p| {:id=>p.id,
                                            :sku=>p.material.sku,
                                            :name=>p.material.name,
                                            :quantity_collected=>p.quantity_collected,
                                            :quantity_adjusted=>p.quantity_adjusted,
                                            :quantity_total=>p.quantity_total,
                                            :material_id=>p.material_id,
                                            }}
    render :text=>return_data.to_json, :layout=>false
  end

end
