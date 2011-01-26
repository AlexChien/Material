class OrderLineItemRawsController < ApplicationController
  before_filter :login_required
  before_filter :check,:only=>["update","destroy"]

  access_control do
    action :update, :destroy, :apply_update, :ext_update, :ext_destroy do
      allow :rc
    end
    action :index, :show, :update_status, :load_data do
      allow :rc, :rm, :wa
    end
    action :check_provide,:print do
      allow :wa
    end
  end

  def index
    olir = OrderLineItemRaw
    olir = olir.in_status([1,2,3,4,5]).in_region(current_user.region) if current_user.has_role?("rc")
    olir = olir.in_status([2,3,4,5]).in_region(current_user.region) if current_user.has_role?("rm")
    olir = olir.in_status([3,4,5]).in_region(current_user.region) if current_user.has_role?("wa")
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

  def show
    @olir = OrderLineItemRaw.find(params[:id])

    if @olir.status == 0
      flash[:error] = "物料未送达"
      redirect_to "/order_line_item_raws"
      return
    end

    if current_user.has_role?("rc") || current_user.has_role?("rm")
      if @olir.region != current_user.region
        flash[:error] = "不能查看他人申请"
        redirect_to "/order_line_item_raws"
        return
      end
    end

    if current_user.has_role?("rm")
      if @olir.status == 1
        flash[:error] = "物料申请中"
        redirect_to "/order_line_item_raws"
        return
      end
    end
  end

  def update_status
    @olir = OrderLineItemRaw.find(params[:id])
    if current_user.has_role?("rc")
      if @olir.status == 1
        @olir.status = 2
        @olir.update_attributes(params[:order_line_item_raw])
        flash[:notice] = "申请已提交，等待区域经理审批"
      end

      if @olir.status == 4
        @olir.update_attribute(:status,5)
        flash[:notice] = "确认已收货，申请完成"
      end
    end

    if current_user.has_role?("rm")
      if @olir.status == 2
        @olir.update_attribute(:status,3)
        flash[:notice] = "审批已通过，等待仓库管理员发货"
      end
    end

    if current_user.has_role?("wa")
      if @olir.status == 3
        i = Inventory.in_region(@olir.region).in_material(@olir.material).first
        if i.nil?
          flash[:error] = "库存不足，不能发放"
        else
          if i.quantity < @olir.apply_quantity
            flash[:error] = "库存不足，不能发放"
          else
            params = {:from_region_id=>@olir.order.region.id,
                      :from_warehouse_id=>Warehouse.in_central(true).first.id,
                      :amount=>"-#{@olir.unit_price*@olir.apply_quantity}",
                      :transfer_type_id=>4,
                      :transfer_line_items_attributes=>{"0"=>{"material_id"=>"#{@olir.material.id}",
                                                              "quantity"=>"-#{@olir.apply_quantity}",
                                                              "unit_price"=>"#{@olir.unit_price}",
                                                              "subtotal"=>"-#{@olir.unit_price*@olir.apply_quantity}",
                                                              "region_id"=>"#{@olir.order.region.id}",
                                                              "salesrep_id"=>"#{@olir.salesrep.id}",
                                                              "warehouse_id"=>"#{Warehouse.in_central(true).first.id}"}}
                      }
            Transfer.new(params).save
            @olir.update_attribute(:status,4)
            flash[:notice] = "货物已发放，等待大区管理员收货"
          end
        end
      end
    end

    redirect_to "/order_line_item_raws/#{@olir.id}"
  end

  def apply_update
    quantity = params[:quantity].to_i
    @olir = OrderLineItemRaw.find(params[:id])
    if @olir.status != 1
      render :text => "不能修改申请总数"
      return
    end
    olia = OrderLineItemAdjusted.in_order(@olir.order.id).in_region(current_user.region.id).in_material(@olir.material.id).first
    if @olir.quantity+quantity < 0
      @error_message = "您的申请总数不能小于0"
    elsif @olir.quantity+quantity > olia.quantity_total
      @error_message = "您的大区预算总数为#{olia.quantity_total}，您的申请总数不能超过大区预算总数"
    else
      @olir.update_attributes(:apply_adjust=>quantity,:apply_quantity=>@olir.quantity+quantity,:apply_subtotal=>@olir.unit_price*(@olir.quantity+quantity))
    end
    render :partial => "rc_apply_list"
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

  def print
    @olir = OrderLineItemRaw.find(params[:id])
    if @olir.status == 3 || @olir.status == 4
      render :layout => "print"
    else
      render :text => "该送货单不能打印"
    end
  end

  def load_data
    @campaign = Campaign.find(params[:campaign_id])
    @olirs = OrderLineItemRaw.in_catalog(@campaign.campaign_catalog.id).in_region(current_user.region.id).all(:order=>"created_at DESC")
    return_data = Hash.new()
    return_data[:size] = @olirs.size
    return_data[:Olirs] = @olirs.collect{|p| {:id=>p.id,
                                              :sku=>p.material.sku,
                                              :name=>p.material.name,
                                              :region=>p.region.name,
                                              :salesrep=>p.salesrep.name,
                                              :unit_price=>p.unit_price,
                                              :quantity=>p.quantity,
                                              :subtotal=>p.subtotal,
                                              :material_id=>p.material_id
                                              }}
    render :text=>return_data.to_json, :layout=>false
  end

  def ext_update
    @olir = OrderLineItemRaw.find(params[:Olirs][:id])
    @campaign = @olir.campaign
    quantity = params[:Olirs][:quantity].to_i
    error_message = ""
    return_data = Hash.new()
    if quantity <= 0
      error_message = "请正确填写预定数量"
    end
    if @campaign.campaign_status != 1
      error_message = "活动已结束，预订不能修改"
    end
    if !@olir.order.nil? && @olir.order.order_status_id != 2
      error_message = "预订不能修改"
    end
    if error_message.blank?
      @olir.update_attributes(:quantity=>quantity,:subtotal=>@olir.unit_price*quantity,:apply_quantity=>quantity,:apply_subtotal=>@olir.unit_price*quantity)
      @olir_total = OrderLineItemRaw.raw_total(@olir.campaign.campaign_catalog.id,current_user.region.id)
      return_data[:success] = true
      success_message = {:notice=>"物料#{@olir.material.name}预定数量为#{@olir.quantity}",
                         :display_text=>"总计：￥",
                         :grand_total=>@olir_total}
      return_data[:message] = success_message
      return_data[:Olirs] = {:id=>@olir.id,
                             :sku=>@olir.material.sku,
                             :name=>@olir.material.name,
                             :region=>@olir.region.name,
                             :salesrep=>@olir.salesrep.name,
                             :unit_price=>@olir.unit_price,
                             :quantity=>@olir.quantity,
                             :subtotal=>@olir.subtotal,
                             :material_id=>@olir.material_id,
                             }
    else
      return_data[:success] = false
      return_data[:message] = error_message
    end
    render :text=>return_data.to_json
  end

  def ext_destroy
    @olir = OrderLineItemRaw.find(params[:Olirs])
    @campaign = @olir.campaign
    return_data = Hash.new()
    if @campaign.campaign_status != 1
      error_message = "活动已结束，预订不能修改"
    end
    if !@olir.order.nil? && @olir.order.order_status_id != 2
      error_message = "预订不能修改"
    end
    if error_message.blank?
      @olir.destroy
      @olir_total = OrderLineItemRaw.raw_total(@olir.campaign.campaign_catalog.id,current_user.region.id)
      return_data[:success] = true
      success_message = {:notice=>"物料#{@olir.material.name}预定已删除",
                         :display_text=>"总计：￥",
                         :grand_total=>@olir_total}
      return_data[:message] = success_message
    else
      return_data[:success] = false
      return_data[:message] = error_message
    end
    render :text=>return_data.to_json
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
