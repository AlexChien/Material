class OrderLineItemAppliesController < ApplicationController
  before_filter :login_required

  access_control do
    allow :rc, :rm, :wa
    action :print do
      allow :wa
    end
    action :index, :show do
      allow :pm, :admin
    end
    action :accept_fail_message, :accept_fail do
      allow :rm
    end
  end

  def index
    olia = OrderLineItemApply
    olia = olia.in_status([1,2,3,4,5]).in_region(current_user.region) if current_user.has_role?("rc")
    olia = olia.in_status([1,2,3,4,5]).in_region(current_user.region) if current_user.has_role?("rm")
    olia = olia.in_status([3,4,5]) if current_user.has_role?("wa")
    olia = olia if current_user.has_role?("pm") || current_user.has_role?("admin")
    @olias = olia.paginate(:all,:include=>[:order_line_item_raw],:per_page=>20,:page => params[:page], :order => 'order_line_item_applies.created_at DESC')
  end

  def show
    @olia = OrderLineItemApply.find(params[:id])
    @olir = @olia.order_line_item_raw

    if current_user.has_role?("rc") || current_user.has_role?("rm")
      if @olir.region != current_user.region
        flash[:error] = "不能查看他人申请"
        redirect_to "/order_line_item_applies"
        return
      end
    end
  end

  def update_status
    @olia = OrderLineItemApply.find(params[:id])
    @olir = @olia.order_line_item_raw
    quantity = @olia.apply_quantity
    if current_user.has_role?("rc")
      if @olia.status == 1
        @olia.status = 2
        @olia.apply_subtotal = params[:order_line_item_apply][:apply_quantity].to_i * @olir.unit_price
        @olia.update_attributes(params[:order_line_item_apply])
        @olir.update_attributes(:apply_size=>@olir.apply_size+@olia.apply_quantity)

        # when RC submits material request to RM
        Role.find_by_name("rm").users.in_region(current_user.region).each do |user|
          PosmMailer.deliver_onStockRequestSubmitted_RC2RM(user,@olia,current_user)
        end

        flash[:notice] = "申请已提交，等待区域经理审批"
      end

      if @olia.status == 4
        @olia.update_attribute(:status,5)

        # when RC receives material package and marks origin request as RECEIVED
        Role.find_by_name("wa").users.each do |user|
          PosmMailer.deliver_onStockReceived(user,@olia,current_user)
        end

        flash[:notice] = "确认已收货，申请完成"
      end
    end

    if current_user.has_role?("rm")
      if @olia.status == 2
        @olia.update_attribute(:status,3)
        @olir.update_attributes(:apply_size=>@olir.apply_size-quantity,:applied_size=>@olir.applied_size+quantity)

        # when RM approves material request sent by RC
        Role.find_by_name("wa").users.each do |user|
          PosmMailer.deliver_onStockRequestApproved_toWA(user,@olia)
        end

        Role.find_by_name("rc").users.in_region(current_user.region).each do |user|
          PosmMailer.deliver_onStockRequestApproved_byRM(user,@olia)
        end

        flash[:notice] = "审批已通过，等待仓库管理员发货"
      end
    end

    if current_user.has_role?("wa")
      if @olia.status == 3
        i = Inventory.in_region(@olir.region).in_material(@olir.material).first
        if i.nil?
          flash[:error] = "库存不足，不能发放"
        else
          if i.quantity < @olia.apply_quantity
            flash[:error] = "库存不足，不能发放"
          else
            params = {:from_region_id=>@olir.order.region.id,
                      :from_warehouse_id=>Warehouse.in_central(true).first.id,
                      :amount=>"-#{@olir.unit_price*@olia.apply_quantity}",
                      :transfer_type_id=>4,
                      :transfer_line_items_attributes=>{"0"=>{"material_id"=>"#{@olir.material.id}",
                                                              "quantity"=>"-#{@olia.apply_quantity}",
                                                              "unit_price"=>"#{@olir.unit_price}",
                                                              "subtotal"=>"-#{@olir.unit_price*@olia.apply_quantity}",
                                                              "region_id"=>"#{@olir.order.region.id}",
                                                              "salesrep_id"=>"#{@olir.salesrep.id}",
                                                              "warehouse_id"=>"#{Warehouse.in_central(true).first.id}"}}
                      }
            Transfer.new(params).save
            @olia.update_attribute(:status,4)
            @olir.update_attributes(:sended_size=>@olir.sended_size+quantity)

            # when WA marks shipping request as SHIPPED
            Role.find_by_name("rc").users.in_region(@olir.region).each do |user|
              PosmMailer.deliver_onStockShipped(user,@olia)
            end

            flash[:notice] = "货物已发放，等待大区管理员收货"
          end
        end
      end
    end
    redirect_to "/order_line_item_applies/#{@olia.id}"
  end

  def print
    @olia = OrderLineItemApply.find(params[:id])
    @olir = @olia.order_line_item_raw
    if @olia.status == 3 || @olia.status == 4
      render :layout => "print"
    else
      render :text => "该送货单不能打印"
    end
  end

  def accept_fail_message
    @olia = OrderLineItemApply.find(params[:id])
    render :partial => "accept_fail_message"
  end

  def accept_fail
    @olia = OrderLineItemApply.find(params[:id])
    @olir = @olia.order_line_item_raw
    if @olia.status == 2
      if @olia.update_attributes(:reason=>params[:reason],:status=>1)
        @olir.update_attribute(:apply_size,@olir.apply_size - @olia.apply_quantity)

        # when RM rejects material request from RC
        Role.find_by_name("rc").users.in_region(current_user.region).each do |user|
          PosmMailer.deliver_onStockRequestRejected_byRM(user,@olia)
        end

        flash[:notice] = "申领审批未通过，等待大区协调员重新修改"
      else
        flash[:error] = "发生未知错误"
      end
    end
    redirect_to "/order_line_item_applies/#{@olia.id}"
  end

end
