class OrderLineItemAppliesController < ApplicationController
  before_filter :login_required

  access_control do
    allow :rc,:rm,:wa
    action :ext_index,:print do
      allow :wa
    end
    action :index, :show do
      allow :pm, :admin, :rm
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

  def ext_index
    olia = OrderLineItemApply
    if current_user.has_role?("wa")
      if params[:status] == "3"
        olia = olia.in_status(3)
      else
        olia = olia.in_status([4,5])
      end
    end

    start = (params[:start] || 1).to_i
    size = (params[:limit] || 20).to_i
    sort_col = (params[:sort] || 'created_at')
    sort_dir = (params[:dir] || 'DESC')

    @olias = olia.all(:order => sort_col+' '+sort_dir,:offset => start, :limit => size)
    return_data = Hash.new()
    return_data[:size] = olia.count
    return_data[:Applies] = @olias.collect{|p| {:id=>p.id,
                                                :sku=>p.material.sku,
                                                :material_name=>p.material.name,
                                                :region=>p.region.name,
                                                :salesrep=>p.salesrep.name,
                                                :show_status=>p.show_status,
                                                :link=>"<a href='/order_line_item_applies/#{p.id}'>#{p.status == 3 ? '去发货' : '查看详细'}</a>"
                                                }}
    render :text=>return_data.to_json, :layout=>false
  end
  
  def new
    @olia = OrderLineItemApply.new
    @material = Material.find(params[:material_id])
  end
  
  def create
    @olia = OrderLineItemApply.new(params[:order_line_item_apply])
    @olia.region = @olia.salesrep.region
    @olia.apply_subtotal = @olia.apply_quantity * @olia.material.cost
    @olia.status = 2
    if @olia.save
      
      # when RC submits material request to RM
      Role.find_by_name("rm").users.in_region(current_user.region).each do |user|
        PosmMailer.deliver_onStockRequestSubmitted_RC2RM(user,@olia,current_user)
      end

      flash[:notice] = "申请已提交，等待区域经理审批"
      redirect_to "/order_line_item_applies"
    else
      flash[:error]  = "物料申领失败，请重新尝试"
      redirect_to "/order_line_item_applies/new?material_id=#{@olia.material.id}"
    end
  end
  
  def calculate_materials
    @material = Material.find(params[:material_id])
    @salesrep = Salesrep.find(params[:salesrep_id])
    @region = @salesrep.region
    i_m = Inventory.in_region(@region.id).in_material(@material.id).first
    quantity = i_m.nil? ? 0 : i_m.quantity
    total_str = ""
    apply_total_5 = OrderLineItemApply.in_salesrep(@salesrep.id).in_material(@material.id).in_status(5).first(:select=>"sum(apply_quantity) as quantity").quantity.to_i
    apply_total = OrderLineItemApply.in_salesrep(@salesrep.id).in_material(@material.id).not_in_status(5).first(:select=>"sum(apply_quantity) as quantity").quantity.to_i
    total_str += "<br/>已提交申领数量：#{apply_total_5+apply_total} （申领中： #{apply_total}  已发货： #{apply_total_5}）"
    olir = OrderLineItemRaw.in_material(@material.id).in_salesrep(@salesrep.id)
    total = olir.first(:select=>"sum(quantity) as total").total.to_i
    total_str += "<br/>共预定数量：#{total}"
    olir.all.each do |olir|
      campaign = olir.campaign
      total_str += "<br/>活动－#{campaign.name}:#{olir.quantity}"
    end
    render :text => "<br/>当前库存量：#{quantity}
                    #{total_str}
                    <script>
                      $('#order_line_item_apply_memo').attr('value','#{@salesrep.memo}');
                      $('#order_line_item_apply_address,#address').attr('value','#{@salesrep.address}');
                    </script>"
  end

  def show
    @olia = OrderLineItemApply.find(params[:id])

    if current_user.has_role?("rc") || current_user.has_role?("rm")
      if @olia.region != current_user.region
        flash[:error] = "不能查看他人申请"
        redirect_to "/order_line_item_applies"
        return
      end
    end
    
    i_m = Inventory.in_region(@olia.region.id).in_material(@olia.material.id).first
    @inventory_quantity = i_m.nil? ? 0 : i_m.quantity
    
    olir = OrderLineItemRaw.in_material(@olia.material.id).in_salesrep(@olia.salesrep.id)
    @raw_total = olir.first(:select=>"sum(quantity) as total").total.to_i
  end

  def update_status
    @olia = OrderLineItemApply.find(params[:id])
    # @olir = @olia.order_line_item_raw
    quantity = @olia.apply_quantity
    if current_user.has_role?("rc")
      if @olia.status == 1
        @olia.status = 2
        @olia.apply_subtotal = params[:order_line_item_apply][:apply_quantity].to_i * @olia.material.cost
        @olia.update_attributes(params[:order_line_item_apply])
        # @olir.update_attributes(:apply_size=>@olir.apply_size+@olia.apply_quantity)

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
        # @olir.update_attributes(:apply_size=>@olir.apply_size-quantity,:applied_size=>@olir.applied_size+quantity)

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
        i = Inventory.in_region(@olia.region).in_material(@olia.material).first
        if i.nil?
          flash[:error] = "库存不足，不能发放"
        else
          if i.quantity < @olia.apply_quantity
            flash[:error] = "库存不足，不能发放"
          else
            params = {:from_region_id=>@olia.region.id,
                      :from_warehouse_id=>Warehouse.in_central(true).first.id,
                      :amount=>"-#{@olia.material.cost*@olia.apply_quantity}",
                      :transfer_type_id=>4,
                      :transfer_line_items_attributes=>{"0"=>{"material_id"=>"#{@olia.material.id}",
                                                              "quantity"=>"-#{@olia.apply_quantity}",
                                                              "unit_price"=>"#{@olia.material.cost}",
                                                              "subtotal"=>"-#{@olia.material.cost*@olia.apply_quantity}",
                                                              "region_id"=>"#{@olia.region.id}",
                                                              "salesrep_id"=>"#{@olia.salesrep.id}",
                                                              "warehouse_id"=>"#{Warehouse.in_central(true).first.id}"}}
                      }
            Transfer.new(params).save
            @olia.update_attribute(:status,4)
            # @olir.update_attributes(:sended_size=>@olir.sended_size+quantity)

            # when WA marks shipping request as SHIPPED
            Role.find_by_name("rc").users.in_region(@olia.region).each do |user|
              PosmMailer.deliver_onStockShipped(user,@olia)
            end

            flash[:notice] = "货物已发放，等待大区管理员收货"
          end
        end
      end
    end
    redirect_to "/order_line_item_applies/#{@olia.id}"
  end

  def update_checked
    correct_count = error_count = 0
    if current_user.has_role?("wa")
      params[:apply_ids].split(",").each do |apply_id|
        @olia = OrderLineItemApply.find(apply_id)
        @olir = @olia.order_line_item_raw
        quantity = @olia.apply_quantity
        i = Inventory.in_region(@olia.region).in_material(@olia.material).first
        if i.nil?
          error_count += 1
        else
          if i.quantity < @olia.apply_quantity
            error_count += 1
          else
            params = {:from_region_id=>@olia.region.id,
                      :from_warehouse_id=>Warehouse.in_central(true).first.id,
                      :amount=>"-#{@olia.material.cost*@olia.apply_quantity}",
                      :transfer_type_id=>4,
                      :transfer_line_items_attributes=>{"0"=>{"material_id"=>"#{@olia.material.id}",
                                                              "quantity"=>"-#{@olia.apply_quantity}",
                                                              "unit_price"=>"#{@olia.material.cost}",
                                                              "subtotal"=>"-#{@olia.material.cost*@olia.apply_quantity}",
                                                              "region_id"=>"#{@olia.region.id}",
                                                              "salesrep_id"=>"#{@olia.salesrep.id}",
                                                              "warehouse_id"=>"#{Warehouse.in_central(true).first.id}"}}
                      }
            Transfer.new(params).save
            @olia.update_attribute(:status,4)
            # @olir.update_attributes(:sended_size=>@olir.sended_size+quantity)

            # when WA marks shipping request as SHIPPED
            Role.find_by_name("rc").users.in_region(@olia.region).each do |user|
              PosmMailer.deliver_onStockShipped(user,@olia)
            end

            correct_count += 1
          end
        end
      end
    end
    if error_count == 0
      flash[:notice] = "成功发放#{correct_count}批物料。"
    else
      flash[:error] = "成功发放#{correct_count}批物料，#{error_count}批物料发放失败，原因为库存不足。"
    end
    redirect_to "/order_line_item_applies"
  end

  def print
    @olia = OrderLineItemApply.find(params[:id])
    if current_user.has_role?("wa")
      if @olia.status == 3 || @olia.status == 4
        render :layout => "print"
      else
        render :text => "该送货单不能打印"
      end
    elsif current_user.has_role?("rc")
      if @olia.status == 5
        render :text => "您没有权限打印该申领单" and return if @olia.region != current_user.region
        render :layout => "print"
      else
        render :text => "该送货单不能打印"
      end
    end
  end

  def accept_fail_message
    @olia = OrderLineItemApply.find(params[:id])
    render :partial => "accept_fail_message"
  end

  def accept_fail
    @olia = OrderLineItemApply.find(params[:id])
    # @olir = @olia.order_line_item_raw
    if @olia.status == 2
      if @olia.update_attributes(:reason=>params[:reason],:status=>1)
        # @olir.update_attribute(:apply_size,@olir.apply_size - @olia.apply_quantity)

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
