class OrderLineItemRawsController < ApplicationController
  before_filter :login_required
  before_filter :check,:only=>["update","destroy"]

  access_control do
    action :update, :destroy, :ext_update, :ext_destroy do
      allow :rc
    end
    action :index, :show, :update_status, :load_data do
      allow :rc
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
      @olir.update_attributes(:quantity=>quantity,:subtotal=>@olir.unit_price*quantity)#,:apply_quantity=>quantity,:apply_subtotal=>@olir.unit_price*quantity
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
    @olia = OrderLineItemApply.new
    if @olir.status == 0
      flash[:error] = "物料未送达"
      redirect_to "/order_line_item_raws"
      return
    end

    if current_user.has_role?("rc")
      if @olir.region != current_user.region
        flash[:error] = "不能查看他人申请"
        redirect_to "/order_line_item_raws"
        return
      end
    end

  end

  def update_status
    @olir = OrderLineItemRaw.find(params[:id])
    @olia = OrderLineItemApply.new(params[:order_line_item_apply])
    @olia.order_line_item_raw = @olir
    @olia.apply_subtotal = @olia.apply_quantity * @olir.unit_price
    @olia.status = 2
    if @olia.save
      @olir.update_attribute(:apply_size,@olir.apply_size+@olia.apply_quantity)

      # when RC submits material request to RM
      Role.find_by_name("rm").users.in_region(current_user.region).each do |user|
        PosmMailer.deliver_onStockRequestSubmitted_RC2RM(user,@olia,current_user)
      end

      flash[:notice] = "申请已提交，等待区域经理审批"
      redirect_to "/order_line_item_applies/#{@olia.id}"
    else
      flash[:error] = "本次申请数量必须大于0"
      render :action => "show"
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
      @olir.update_attributes(:quantity=>quantity,:subtotal=>@olir.unit_price*quantity)#,:apply_quantity=>quantity,:apply_subtotal=>@olir.unit_price*quantity
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
