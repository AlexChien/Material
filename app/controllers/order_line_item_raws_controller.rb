class OrderLineItemRawsController < ApplicationController
  before_filter :login_required

  access_control do
    allow :rc
  end
  
  def update
    o = OrderLineItemRaw.find(params[:id])
    quantity = params[:quantity].to_i
    if quantity <= 0
      @error_message = "请正确填写预定数量"
      @material = o.material
    else
      o.update_attributes(:quantity=>quantity,:subtotal=>o.unit_price*quantity)
    end
    init_list
    render :partial => "campaigns/order_list"
  end
  
  def destroy
    o = OrderLineItemRaw.find(params[:id])
    o.destroy
    init_list
    render :partial => "campaigns/order_list"
  end
  
  def init_list
    @campaign = Campaign.find(params[:campaign_id])
    olir = OrderLineItemRaw
    olir = olir.in_catalog(@campaign.campaign_catalog.id)
    @olirs = olir.all(:order=>"created_at DESC")
  end
  
end
