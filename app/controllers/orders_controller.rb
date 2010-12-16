class OrdersController < ApplicationController
  before_filter :login_required
  before_filter :check_order,:only=>[:create]

  access_control do
    allow :rc
  end

  def create
      @order = Order.new(params[:order])
      @order.campaign = @campaign
      @order.order_status_id = 1
      @order.region = current_user.region
      amount = @olirs.first(:select=>"sum(subtotal) as raw_total").raw_total.to_f
      @order.amount = amount
      Order.transaction do
        if @order.save
          @olirs.all.each do |olir|
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
    redirect_to "/orders/#{@order.id}"
  end

  def show
    @order = Order.find(params[:id])
    if @order.region != current_user.region
      flash[:error] = "不能查看他人订单"
      redirect_to "/campaigns"
    end
  end

protected
  def check_order
    @catalog = Catalog.find(params[:order][:catalog_id])
    @campaign = @catalog.campaign
    @olirs = OrderLineItemRaw.in_region(current_user.region.id).in_catalog(@catalog.id)
    if @olirs.empty?
      flash[:error] = "订单不能空"
      redirect_to "/campaigns/#{@campaign}/book"
      return
    end
    order = Order.in_region(current_user.region.id).in_catalog(@catalog.id).first
    if !order.nil?
      flash[:error] = "订单不能重复提交"
      redirect_to "/orders/#{order.id}"
      return
    end
    if @campaign.campaign_status != 1
      flash[:error] = "预订未开始或者预订已结束"
      redirect_to "/campaigns"
      return
    end
  end

end
