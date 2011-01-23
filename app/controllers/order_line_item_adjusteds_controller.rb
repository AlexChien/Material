class OrderLineItemAdjustedsController < ApplicationController
  before_filter :login_required
  before_filter :check,:only=>[:update]

  access_control do
    action :load_data do
      allow :pm
    end
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

  def load_data
    @order = Order.find(params[:order_id])
    @olias = @order.order_line_item_adjusteds
    return_data = Hash.new()
    return_data[:size] = @olias.size
    return_data[:Olias] = @olias.collect{|p| {:id=>p.id,
                                              :sku=>p.material.sku,
                                              :name=>p.material.name,
                                              :region=>p.region.name,
                                              :unit_price=>p.unit_price,
                                              :min_num=>p.material.min_num,
                                              :max_num=>p.material.max_num,
                                              :quantity_collected=>p.quantity_collected,
                                              :quantity_adjust=>p.quantity_adjust,
                                              :quantity_total=>p.quantity_total,
                                              :subtotal=>p.subtotal,
                                              :material_id=>p.material_id
                                              }}
    render :text=>return_data.to_json, :layout=>false
  end

  def ext_update
    @olia = OrderLineItemAdjusted.find(params[:Olias][:id])
    quantity_adjust = params[:Olias][:quantity_adjust].to_i
    quantity_total = @olia.quantity_collected+quantity_adjust
    error_message = ""
    return_data = Hash.new()
    if quantity_total < 0
      error_message = "预定总数不能小于0"
    end
    if @olia.order.campaign.campaign_status != 1
      error_message = "活动已结束，不能调整数量"
    end
    if !(@olia.order.order_status_id == 1 || @olia.order.order_status_id == 4)
      error_message = "订单已提交，不能调整数量"
    end
    if error_message.blank?
      @olia.update_attributes(:quantity_adjust=>quantity_adjust,
                              :quantity_total=>quantity_total,
                              :subtotal=>@olia.unit_price*quantity_total)
      @olir_total = @olia.order.order_line_item_adjusteds.first(:select=>"sum(subtotal) as subtotal").subtotal.to_f
      return_data[:success] = true
      success_message = {:notice=>"物料#{@olia.material.name}数量调整为#{@olia.quantity_adjust}预定总数为#{@olia.quantity_total}",
                         :olia_total=>"预定总计：￥#{@olir_total}<br/>可使用预算：￥#{current_user.region.redeemable_budget}<br/>将剩余预算：￥#{current_user.region.redeemable_budget - @olir_total}<br/>"}
      return_data[:message] = success_message
      return_data[:Olias] = {:id=>@olia.id,
                             :sku=>@olia.material.sku,
                             :name=>@olia.material.name,
                             :region=>@olia.region.name,
                             :unit_price=>@olia.unit_price,
                             :min_num=>@olia.material.min_num,
                             :max_num=>@olia.material.max_num,
                             :quantity_collected=>@olia.quantity_collected,
                             :quantity_adjust=>@olia.quantity_adjust,
                             :quantity_total=>@olia.quantity_total,
                             :subtotal=>@olia.subtotal,
                             :material_id=>@olia.material_id
                             }
    else
      return_data[:success] = false
      return_data[:message] = error_message
    end
    render :text=>return_data.to_json
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
