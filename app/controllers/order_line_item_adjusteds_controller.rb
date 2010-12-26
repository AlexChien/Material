class OrderLineItemAdjustedsController < ApplicationController
  before_filter :login_required
  before_filter :check

  access_control do
    allow :rm
  end

  def update
    quantity_adjust = params[:quantity_adjust].to_i
    quantity_total = @olia.quantity_collected+quantity_adjust
    if quantity_total < 0
      @error_message = "预定总数不能小于0"
    end
    @olia.update_attributes(:quantity_adjust=>quantity_adjust,
                            :quantity_total=>quantity_total,
                            :subtotal=>@olia.unit_price*quantity_total) if @error_message.blank?
    @order = @olia.order
    render :partial => "orders/rm_order_list"
  end

protected
  def check
    @campaign = Campaign.find(params[:campaign_id])
    @olia = OrderLineItemAdjusted.find(params[:id])
    if @campaign.campaign_status != 1
      flash[:error] = "活动已结束，不能调整数量"
      redirect_to "/orders"
    end
    if !(@olia.order.order_status_id == 1 || @olia.order.order_status_id == 4)
      flash[:error] = "订单已提交，不能调整数量"
      redirect_to "/orders"
    end
  end
end
