class OrderLineItemAdjustedsController < ApplicationController
  before_filter :login_required
  before_filter :check,:only=>[:update]

  access_control do
    action :load_data do
      allow :pm, :admin
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
    if params[:type] == "detail"
      @olirs = @order.order_line_item_raws
      return_data = Hash.new()
      return_data[:size] = @olirs.size
      return_data[:Olirs] = @olirs.collect{|p| {:id=>p.id,
                                                :sku=>p.material.sku,
                                                :name=>p.material.name,
                                                :region=>p.region.name,
                                                :salesrep=>p.salesrep.name,
                                                :unit_price=>p.unit_price,
                                                :quantity=>p.quantity,
                                                :adjusted_size=>p.adjusted_size,
                                                :quantity_total=>p.quantity+p.adjusted_size,
                                                :subtotal=>p.subtotal+p.unit_price*p.adjusted_size,
                                                :material_id=>p.material_id
                                                }}
    else
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
    end
    render :text=>return_data.to_json, :layout=>false
  end

  def ext_update
    if params[:type] == "detail"
      @olir = OrderLineItemRaw.find(params[:Olirs][:id])
      quantity_adjust = params[:Olirs][:adjusted_size].to_i
      current_adjust = @olir.adjusted_size
      error_message = ""
      return_data = Hash.new()
      if @olir.quantity+quantity_adjust < 0
        error_message = "预定数量不能小于0"
      end
      if @olir.order.campaign.campaign_status != 1
        error_message = "活动已结束，不能调整数量"
      end
      if !(@olir.order.order_status_id == 1 || @olir.order.order_status_id == 4)
        error_message = "订单已提交，不能调整数量"
      end
      if error_message.blank?
        @olia = OrderLineItemAdjusted.in_order(@olir.order).in_material(@olir.material).in_region(current_user.region).first
        if @olia
          @olir.update_attributes(:adjusted_size=>quantity_adjust)
          olia_quantity_adjust = @olia.quantity_adjust + quantity_adjust - current_adjust
          olia_quantity_total = @olia.quantity_collected + olia_quantity_adjust
          @olia.update_attributes(:quantity_adjust=>olia_quantity_adjust,:quantity_total=>olia_quantity_total,:subtotal=>olia_quantity_total * @olia.unit_price)
          return_data[:success] = true
          success_message = {:notice=>"物料#{@olir.material.name}数量调整为#{@olir.adjusted_size}预定总数为#{@olir.quantity+@olir.adjusted_size}"}
          return_data[:message] = success_message
          return_data[:Olirs] = {:id=>@olir.id,
                                 :sku=>@olir.material.sku,
                                 :name=>@olir.material.name,
                                 :region=>@olir.region.name,
                                 :salesrep=>@olir.salesrep.name,
                                 :unit_price=>@olir.unit_price,
                                 :quantity=>@olir.quantity,
                                 :adjusted_size=>@olir.adjusted_size,
                                 :quantity_total=>@olir.quantity+@olir.adjusted_size,
                                 :subtotal=>@olir.subtotal+@olir.unit_price*@olir.adjusted_size,
                                 :material_id=>@olir.material_id
                                 }
        end
      else
        return_data[:success] = false
        return_data[:message] = error_message
      end
    else
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
        b = Budget.in_region(@olia.region).in_campaign(@olia.order.campaign).first
        success_message = {:notice=>"物料#{@olia.material.name}数量调整为#{@olia.quantity_adjust}预定总数为#{@olia.quantity_total}",
                           :display_text=>"预定总计：￥#{@olir_total}<br/>可使用预算：￥#{b.redeemable_budget}<br/>将剩余预算：￥#{(b.redeemable_budget*1000 - @olir_total*1000)/1000}<br/>",
                           # :display_text=>"预定总计：￥#{@olir_total}<br/>可使用预算：￥#{current_user.region.redeemable_budget}<br/>将剩余预算：￥#{(current_user.region.redeemable_budget*1000 - @olir_total*1000)/1000}<br/>",
                           :grand_total=>"defined"}
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
