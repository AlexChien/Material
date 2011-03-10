class OrdersController < ApplicationController
  before_filter :login_required
  before_filter :check_order,:only=>[:create]

  access_control do
    action :create, :print do
      allow :rc
    end
    # action :index,:provide, :update do
    #   allow :wa
    # end
    action :index, :show, :update, :ext_index do
      allow :rc, :rm, :pm, :admin
    end
    action :approve_fail_message, :approve_fail do
      allow :rm
    end
    action :accept_fail_message, :accept_fail, :print do
      allow :pm, :admin
    end
  end

  def index
    order = Order
    order = order.in_region(current_user.region.id) if current_user.has_role?("rm")
    order = order.in_region(current_user.region.id) if current_user.has_role?("rc")
    order = order.in_region(current_user.region.id).in_order_status(8) if current_user.has_role?("wa")
    @orders = order.paginate(:all,:per_page=>20,:page => params[:page], :order => 'orders.created_at DESC')
  end

  def ext_index
    order = Order

    start = (params[:start] || 1).to_i
    size = (params[:limit] || 20).to_i
    sort_col = (params[:sort] || 'created_at')
    sort_dir = (params[:dir] || 'DESC')

    @orders = order.all(:order => sort_col+' '+sort_dir,:offset => start, :limit => size)
    return_data = Hash.new()
    return_data[:size] = order.count
    return_data[:Orders] = @orders.collect{|p| {:id=>p.id,
                                                :order_status=>p.order_status.name,
                                                :amount=>p.amount,
                                                :region=>p.region.name,
                                                :campaign=>p.campaign.name,
                                                :catalog_startdate=>p.campaign.catalog_startdate,
                                                :catalog_enddate=>p.campaign.catalog_enddate,
                                                :show_status=>p.campaign.show_status,
                                                :link=>"<a href='/orders/#{p.id}'>#{p.order_status_id == 3 ? '接受订单' : '查看订单'}</a>"
                                                }}
    render :text=>return_data.to_json, :layout=>false
  end

  def create
      order = Order.in_region(current_user.region.id).in_catalog(@catalog.id).first
      if order.nil?
        @order = Order.new(params[:order])
        @order.campaign = @campaign
        @order.region = current_user.region
      else
        @order = order
        @order.memo = nil
      end
      @order.order_status_id = 1
      amount = @olirs.first(:select=>"sum(subtotal) as raw_total").raw_total.to_f
      @order.amount = amount
      Order.transaction do
        if @order.save
          @order.order_line_item_adjusteds.destroy_all
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

          # when RC collected orders from RPs and submitted order to RM for review
          Role.find_by_name("rm").users.in_region(current_user.region).each do |user|
            PosmMailer.deliver_onOrderSubmitted_RC2RM(user,@order,current_user)
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
    @campaign = @order.campaign
    if current_user.has_role?("rc") || current_user.has_role?("rm")
      if @order.region != current_user.region
        flash[:error] = "不能查看他人订单"
        redirect_to "/dashboard"
        return
      end
    end
    if current_user.has_role?("rc")
      if @order.order_status_id == 2
        redirect_to "/campaigns/#{@order.campaign.id}/book"
      elsif @order.order_status_id == 6 || @order.order_status_id == 7
        @olirs = OrderLineItemRaw.in_catalog(@campaign.campaign_catalog.id).in_region(current_user.region.id).all(:order=>"created_at DESC")
        render :template => "/orders/rc_apply"
      else
        render :template => "/orders/rc_show"
      end
    elsif current_user.has_role?("rm")
      if @order.campaign.campaign_status == 2 && @order.order_status_id ==1
        flash[:error] = "活动已过期"
        redirect_to "/dashboard"
        return
      end
      if @order.order_status_id == 7
        @olirs = OrderLineItemRaw.in_catalog(@campaign.campaign_catalog.id).in_region(current_user.region.id).all(:order=>"created_at DESC")
        render :template => "/orders/rm_apply_show"
      else
        render :template => "/orders/rm_show"
      end
    elsif current_user.has_role?("pm") || current_user.has_role?("admin")
      render :template => "/orders/pm_show"
    end
  end

  def update
    @order = Order.find(params[:id])
    amount = @order.order_line_item_adjusteds.first(:select=>"sum(subtotal) as subtotal").subtotal.to_f
    @order.order_line_item_adjusteds.each do |olia|
      if olia.material.min_num > olia.quantity_total
        @num_error = "物料未达到最小起订量，请调整数量或返回RC重新预定"
      elsif olia.material.max_num < olia.quantity_total
        @num_error = "物料超过最大订货量，请调整数量或返回RC重新预定"
      end
    end
    if amount > @order.region.redeemable_budget
      flash[:error] = "您的订单超过预算使用额度，请重新修改订单"
    elsif @num_error
      flash[:error] = @num_error
    else
      if current_user.has_role?("rm")
        if @order.order_status_id == 1 || @order.order_status_id == 4
          @order.update_attributes(:amount=>amount,:order_status_id=>3,:memo=>nil)

          # when RM approves the order submitted from RC for review
          Role.find_by_name("rc").users.in_region(current_user.region).each do |user|
            PosmMailer.deliver_onOrderApproved_byRM(user,@order)
          end

          # when submitted order to PM for review
          Role.find_by_name("pm").users.each do |user|
            PosmMailer.deliver_onOrderSubmitted_RM2PM(user,@order,current_user)
          end

          flash[:notice] = "订单已提交总部，等待总部审核"
        end
        if @order.order_status_id == 7
          @order.update_attributes(:order_status_id=>8,:memo=>nil)
          flash[:notice] = "申请已批准，等待仓库管理员发货"
        end
      elsif current_user.has_role?("pm") || current_user.has_role?("admin")
        if @order.order_status_id == 3
          @order.update_attributes(:amount=>amount,:order_status_id=>5,:memo=>nil)
          @order.region.update_attribute(:used_budget,@order.region.used_budget+amount)

          # when PM approves the order submitted from RM for review
          Role.find_by_name("rm").users.in_region(@order.region).each do |user|
            PosmMailer.deliver_onOrderApproved_byPM(user,@order)
          end

          flash[:notice] = "总部接受订单"
        end
      elsif current_user.has_role?("rc")
        if @order.order_status_id == 6
          @order.update_attributes(:order_status_id=>7,:memo=>nil)
          flash[:notice] = "申请已提交，等待区域经理审批"
        end
      elsif current_user.has_role?("wa")
        if @order.order_status_id == 8
          @order.order_line_item_raws.each do |olir|
            provide = params["provide_#{olir.id}".to_sym].to_i
            params = {:from_region_id=>@order.region.id,
                      :from_warehouse_id=>@order.region.warehouse.id,
                      :transfer_type_id=>4,
                      :transfer_line_items_attributes=>{"0"=>{"material_id"=>"#{olir.material.id}",
                                                              "quantity"=>"-#{provide}",
                                                              "unit_price"=>"#{olir.unit_price}",
                                                              "subtotal"=>"-#{olir.unit_price*provide}",
                                                              "region_id"=>"#{@order.region.id}",
                                                              "warehouse_id"=>"#{@order.region.warehouse.id}"}}
                      }
            Transfer.new(params).save
          end
          @order.update_attributes(:order_status_id=>9,:memo=>nil)
          flash[:notice] = "物料已发放"
          redirect_to "/orders"
          return
        end
      end
    end
    redirect_to "/orders/#{@order.id}"
  end

  def approve_fail_message
    @order = Order.find(params[:id])
    render :partial => "approve_fail_message"
  end

  def approve_fail
    @order = Order.find(params[:id])
    if @order.order_status_id == 1
      if @order.update_attributes(:memo=>params[:memo],:order_status_id=>2)

        # when RM rejects the order submitted from RC for review
        Role.find_by_name("rc").users.in_region(current_user.region).each do |user|
          PosmMailer.deliver_onOrderRejected_RM2RC(user,@order)
        end

        flash[:notice] = "订单审批未通过，等待大区协调员重新修改"
      else
        flash[:error] = "发生未知错误"
      end
    end
    redirect_to "/orders/#{@order.id}"
  end

  def accept_fail_message
    @order = Order.find(params[:id])
    render :partial => "accept_fail_message"
  end

  def accept_fail
    @order = Order.find(params[:id])
    if @order.order_status_id == 3
      if @order.update_attributes(:memo=>params[:memo],:order_status_id=>4)

        # when PM approves the order submitted from RM for review
        Role.find_by_name("rm").users.in_region(@order.region).each do |user|
          PosmMailer.deliver_onOrderRejected_PM2RM(user,@order)
        end

        flash[:notice] = "总部拒绝订单，等待大区管理员重新修改"
      else
        flash[:error] = "发生未知错误"
      end
    end
    redirect_to "/orders/#{@order.id}"
  end

  def provide
    @order = Order.find(params[:id])
    @campaign = @order.campaign
    @olirs = OrderLineItemRaw.in_catalog(@campaign.campaign_catalog.id).in_region(current_user.region.id).all(:order=>"created_at DESC")
  end

  def print
    @order = Order.find(params[:id])
    if @order.order_status_id == 5

      if current_user.has_role?("rc")
        render :text => "您没有权限打印该订单" and return if current_user.region != @order.region
      end

      render :layout => "print"
    else
      render :text => "该预定单不能打印"
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
    if @campaign.campaign_status != 1
      flash[:error] = "预订未开始或者预订已结束"
      redirect_to "/campaigns"
      return
    end
  end

end
