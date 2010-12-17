class OrderLineItemRawsController < ApplicationController
  before_filter :login_required
  before_filter :check

  access_control do
    allow :rc
  end

  def update
    quantity = params[:quantity].to_i
    if quantity <= 0
      @error_message = "请正确填写预定数量"
      @material = @olir.material
    else
      @olir.update_attributes(:quantity=>quantity,:subtotal=>@olir.unit_price*quantity)
    end
    init_list
    render :partial => "campaigns/order_list"
  end

  def destroy
    @olir.destroy
    init_list
    render :partial => "campaigns/order_list"
  end

  def init_list
    olir = OrderLineItemRaw
    olir = olir.in_catalog(@campaign.campaign_catalog.id).in_region(current_user.region.id)
    @olirs = olir.all(:order=>"created_at DESC")
  end

protected
  def check
    @campaign = Campaign.find(params[:campaign_id])
    @olir = OrderLineItemRaw.find(params[:id])
    if @campaign.campaign_status != 1
      flash[:error] = "活动已结束，预订不能修改"
      redirect_to "/campaigns"
    end
    if !@olir.order.nil?
      flash[:error] = "订单已生成，预订不能修改"
      redirect_to "/campaigns"
    end
  end

end
