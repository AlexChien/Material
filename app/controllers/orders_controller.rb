class OrdersController < ApplicationController
  before_filter :login_required

  access_control do
    allow :rc
  end

  def create
    @catalog = Catalog.find(params[:order][:catalog_id])
    @campaign = @catalog.campaign
    olirs = OrderLineItemRaw.in_region(current_user.region.id).in_catalog(@catalog.id)
    order = Order.in_region(current_user.region.id).in_catalog(@catalog.id).first
    if olirs.empty?
      flash[:error] = "订单不能空"
    else
      if order.nil?
        @order = Order.new(params[:order])
        @order.campaign = @campaign
        @order.order_status_id = 1
        @order.region = current_user.region
        amount = olirs.first(:select=>"sum(subtotal) as raw_total").raw_total.to_f
        @order.amount = amount
        Order.transaction do
          if @order.save
            olirs.all.each do |olir|
              olir.update_attribute(:order,@order)
              OrderLineItemAdjusted.create(:order=>@order,
                                           :material=>olir.material,
                                           :region=>current_user.region,
                                           :quantity_collected=>olir.quantity,
                                           :quantity_total=>olir.quantity,
                                           :unit_price=>olir.unit_price,
                                           :subtotal=>olir.subtotal)
            end
            flash[:notice] = "订单已提交，待大区经理审核"
          else
            flash[:error] = "订单提交错误"
          end
        end
      else
        flash[:error] = "订单已提交，不能再生成"
      end
    end
    redirect_to "/campaigns/#{@campaign.id}/book"
  end

end
