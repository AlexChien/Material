class OrderLineItemAppliesController < ApplicationController
  before_filter :login_required

  access_control do
    allow :rc, :rm, :wa
    action :print do
      allow :wa
    end
  end

  def index
    olia = OrderLineItemApply
    olia = olia.in_status([1,2,3,4,5]).in_region(current_user.region) if current_user.has_role?("rc")
    olia = olia.in_status([2,3,4,5]).in_region(current_user.region) if current_user.has_role?("rm")
    olia = olia.in_status([3,4,5]).in_region(current_user.region) if current_user.has_role?("wa")
    @olias = olia.paginate(:all,:per_page=>20,:page => params[:page], :order => 'order_line_item_applies.created_at DESC')
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

    if current_user.has_role?("rm")
      if @olia.status == 1
        flash[:error] = "物料申请中"
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
        @olia.update_attributes(params[:order_line_item_apply])
        flash[:notice] = "申请已提交，等待区域经理审批"
      end

      if @olia.status == 4
        @olia.update_attribute(:status,5)
        flash[:notice] = "确认已收货，申请完成"
      end
    end

    if current_user.has_role?("rm")
      if @olia.status == 2
        @olia.update_attribute(:status,3)
        @olir.update_attributes(:apply_size=>@olir.apply_size-quantity,:applied_size=>@olir.applied_size+quantity)
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

end
