class OrderLineItemRawsController < ApplicationController
  before_filter :login_required
  before_filter :check,:except=>["apply_update","check_provide","index","apply"]

  access_control do
    action :index, :apply, :update, :destroy, :apply_update do
      allow :rc
    end
    action :check_provide do
      allow :wa
    end
  end

  def index
    olir = OrderLineItemRaw
    olir = olir.in_status(1).in_region(current_user.region)
    @olirs = olir.paginate(:all,:include=>[:campaign,:material,:region,:salesrep],:per_page=>20,:page => params[:page], :order => 'order_line_item_raws.created_at DESC')
  end

  def update
    quantity = params[:quantity].to_i
    if quantity <= 0
      @error_message = "请正确填写预定数量"
      @material = @olir.material
    else
      @olir.update_attributes(:quantity=>quantity,:subtotal=>@olir.unit_price*quantity,:apply_quantity=>quantity,:apply_subtotal=>@olir.unit_price*quantity)
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

  def apply
    @olir = OrderLineItemRaw.find(params[:id])
    if @olir.region != current_user.region
      flash[:error] = "不能查看他人申请"
      redirect_to "/order_line_items"
      return
    end
  end

  def apply_update
    quantity = params[:quantity].to_i
    @campaign = Campaign.find(params[:campaign_id])
    @olir = OrderLineItemRaw.find(params[:id])
    olia = OrderLineItemAdjusted.in_order(@olir.order.id).in_region(current_user.region.id).in_material(@olir.material.id).first
    if @olir.quantity+quantity < 0
      @error_message = "您的申请总数不能小于0"
    elsif @olir.quantity+quantity > olia.quantity_total
      @error_message = "您的大区预算总数为#{olia.quantity_total}，您的申请总数不能超过大区预算总数"
    else
      @olir.update_attributes(:apply_adjust=>quantity,:apply_quantity=>@olir.quantity+quantity,:apply_subtotal=>@olir.unit_price*(@olir.quantity+quantity))
    end
    @order = @olir.order
    @olirs = OrderLineItemRaw.in_catalog(@campaign.campaign_catalog.id).in_region(current_user.region.id).all(:order=>"created_at DESC")
    render :partial => "orders/rc_apply_list"
  end

  def check_provide
    @olir = OrderLineItemRaw.find(params[:id])
    i = Inventory.in_material(@olir.material.id).in_region(@olir.region.id).first
    if params[:quantity].to_i < 0
      @error_message = "发放数量不能小于0"
    elsif i.quantity < params[:quantity].to_i
      @error_message = "仓库库存量不足"
    end
    render :partial=>"message"
  end

protected
  def check
    @campaign = Campaign.find(params[:campaign_id])
    @olir = OrderLineItemRaw.find(params[:id])
    if @campaign.campaign_status != 1
      flash[:error] = "活动已结束，预订不能修改"
      redirect_to "/campaigns"
      return
    end
    if !@olir.order.nil? && @olir.order.order_status_id != 2
      flash[:error] = "预订不能修改"
      redirect_to "/campaigns"
      return
    end
  end

end
