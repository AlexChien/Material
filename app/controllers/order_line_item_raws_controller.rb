class OrderLineItemRawsController < ApplicationController
  before_filter :login_required
  before_filter :check_campaign

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
    olir = OrderLineItemRaw
    olir = olir.in_catalog(@campaign.campaign_catalog.id).in_region(current_user.region.id)
    @olirs = olir.all(:order=>"created_at DESC")
  end

private
  def check_campaign
    @campaign = Campaign.find(params[:campaign_id])
    if @campaign.campaign_status != 1
      flash[:error] = "预订不能修改"
      redirect_to "/campaigns"
    end
  end

end
