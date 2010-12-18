class OrdersController < ApplicationController
  before_filter :login_required
  before_filter :check_order,:only=>[:create]

  access_control do
    action :create do
      allow :rc
    end
    action :show do
      allow :rc, :rm
    end
    action :index, :update do
      allow :rm
    end
  end
  
  def index
    order = Order
    order = order.in_region(current_user.region.id)
    @orders = order.paginate(:all,:per_page=>20,:page => params[:page], :order => 'orders.created_at DESC')
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
            olia = OrderLineItemAdjusted.in_region(current_user.region.id).in_material(olir.material.id).in_order(@order.id).first
            if olia.nil?
              OrderLineItemAdjusted.create(:order=>@order,
                                           :material=>olir.material,
                                           :region=>current_user.region,
                                           :quantity_collected=>olir.quantity,
                                           :quantity_total=>olir.quantity,
                                           :unit_price=>olir.unit_price,
                                           :subtotal=>olir.subtotal)
            else
              olia.update_attributes(:quantity_collected=>olia.quantity_collected+olir.quantity,
                                     :quantity_total=>olia.quantity_total+olir.quantity,
                                     :subtotal=>olia.subtotal+olir.subtotal)
            end
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
      redirect_to "/dashboard"
      return
    end
    if current_user.has_role?("rc")
      render :template => "/orders/rc_show"
    elsif current_user.has_role?("rm")
      if @order.campaign.campaign_status == 2 && @order.order_status_id ==1 
        flash[:error] = "活动已过期"
        redirect_to "/dashboard"
        return
      end
      render :template => "/orders/rm_show"
    end
  end

  def update
    @order = Order.find(params[:id])
    amount = @order.order_line_item_adjusteds.first(:select=>"sum(subtotal) as subtotal").subtotal.to_f
    if amount > current_user.region.assigned_budget
      flash[:error] = "您的订单超过预算额度，请重新修改订单"
    else
      if @order.order_status_id == 1
        @order.update_attributes(:amount=>amount,:order_status_id=>2)
        flash[:notice] = "订单已提交总部，等待总部审核"
      else
        flash[:error] = "订单已提交，不能重复修改"
      end
    end
    redirect_to "/orders/#{@order.id}"
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
