class CampaignsController < ApplicationController
  before_filter :login_required
  before_filter :check_campaign,:only=>[:raw]
  before_filter :check_campaign_status,:only=>[:edit,:update,:destroy]

  access_control do
    action :index do
      allow :pm,:rc,:admin
    end
    action :new, :create, :edit, :update, :destroy, :production do
      allow :pm,:admin
    end
    action :book,:raw do
      allow :rc
    end
  end

  def index
    campaign = Campaign
    campaign = campaign.in_state("activated")
    if current_user.has_role?("rc")
      campaign_ids = []
      Order.in_region(current_user.region).each do |order|
        campaign_ids << order.campaign_id
      end
      campaign = campaign.not_in_id(campaign_ids) unless campaign_ids.empty?
    end
    @campaigns = campaign.paginate(:all,:include=>[:catalogs],:per_page=>20,:page => params[:page], :order => 'campaigns.created_at DESC')
  end

  def new
    @campaign = Campaign.new
    @campaign.catalogs.build
  end

  def create
    @campaign = Campaign.new(params[:campaign])
    if @campaign.save
      unless params[:material_ids].nil?
        params[:material_ids].each do |material_id|
          price = params["price_#{material_id}".to_sym].to_f
          catalog = @campaign.catalogs.first
          cm = CatalogsMaterial.new
          cm.catalog = catalog
          cm.price = (price >= 0 ? price : 0)
          cm.material_id = material_id
          cm.save
        end
      end
      redirect_to "/campaigns"
      flash[:notice] = "活动#{@campaign.name}添加成功"
    else
      flash[:error]  = "添加失败，请重新尝试"
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @campaign.update_attributes(params[:campaign])
      @campaign.catalogs.first.materials.delete_all
      unless params[:material_ids].nil?
        params[:material_ids].each do |material_id|
          price = params["price_#{material_id}".to_sym].to_f
          catalog = @campaign.catalogs.first
          cm = CatalogsMaterial.new
          cm.catalog = catalog
          cm.price = (price >= 0 ? price : 0)
          cm.material_id = material_id
          cm.save
        end
      end
      flash[:notice] = "#{@campaign.name} 修改成功"
      redirect_to "/campaigns"
    else
      flash[:error] = "#{@campaign.name} 修改失败"
      render :action => "edit"
    end
  end

  def destroy
    if @campaign.delete_campaign!
      flash[:notice] = "#{@campaign.name} 删除成功"
    else
      flash[:error] = "发生未知错误，请联系管理员"
    end
    redirect_to "/campaigns"
  end

  def book
    @campaign = Campaign.find(params[:id])
    @cms = CatalogsMaterial.in_catalog(@campaign.campaign_catalog.id).all(:order=>"created_at DESC")
    @olirs = OrderLineItemRaw.in_catalog(@campaign.campaign_catalog.id).in_region(current_user.region.id).all(:order=>"created_at DESC")
    @salesreps = Salesrep.in_state("activated").in_region(current_user.region).all(:order=>"created_at DESC")
    order = Order.in_catalog(@campaign.campaign_catalog.id).in_region(current_user.region.id)
    @campaign_order = order.first
    @campaign_order_2 = order.not_in_order_status(2).first
  end

  def raw
    num = params[:num].to_i
    @material = Material.find(params[:material_id])
    @cm = CatalogsMaterial.in_catalog(@campaign.campaign_catalog.id).in_material(@material.id).first
    check(num,params[:salesrep_id])
    if @error_message.nil?
      salesrep = Salesrep.find(params[:salesrep_id])
      exist_olir = OrderLineItemRaw.in_catalog(@campaign.campaign_catalog.id).in_salesrep(salesrep.id).in_material(@material.id).in_region(current_user.region.id).first
      if exist_olir.nil?
        OrderLineItemRaw.create(:campaign=>@campaign,
                                :catalog=>@campaign.campaign_catalog,
                                :material=>@material,
                                :region=>current_user.region,
                                :quantity=>num,
                                :unit_price=>@cm.price,
                                :subtotal=>num * @cm.price,
                                :apply_quantity=>num,
                                :apply_subtotal=>num * @cm.price,
                                :salesrep=>salesrep)
      else
        exist_olir.update_attributes(:quantity=>exist_olir.quantity+num,:subtotal=>exist_olir.subtotal+num * @cm.price)
      end
    end
    @olirs = OrderLineItemRaw.in_catalog(@campaign.campaign_catalog.id).in_region(current_user.region.id).all(:order=>"created_at DESC")
    render :partial => "order_list"
  end

  def production
    @campaign = Campaign.find(params[:id])
    @catalog = @campaign.campaign_catalog
    @production = @catalog.production
    if @production.nil?
      order_ids = []
      @catalog.orders.in_order_status(5).each do |order|
        order_ids << order.id
      end
      olias = OrderLineItemAdjusted.in_order(order_ids).all(:select=>"sum(quantity_total) as quantity_total,order_line_item_adjusteds.*",:group=>"material_id")
      Production.transaction do
        @production = Production.create(:campaign=>@campaign,:catalog=>@catalog)
        olias.each do |olia|
          puts olia.material
          puts olia.quantity_total
          ProductionLineItem.create(:production=>@production,
                                    :material=>olia.material,
                                    :quantity_collected=>olia.quantity_total,
                                    :quantity_total=>olia.quantity_total)
        end
      end
    end
    redirect_to "/productions/#{@production.id}"
  end

private

  def check(num,salesrep)
    if num <= 0
      @error_message = "请正确填写预定数量"
      return
    end
    if salesrep.blank?
      @error_message = "请选择销售代表"
      return
    end
  end

  def check_campaign
    @campaign = Campaign.find(params[:id])
    if @campaign.campaign_status != 1
      flash[:error] = "活动不能预订"
      redirect_to "/campaigns"
    end
  end

  def check_campaign_status
    @campaign = Campaign.find(params[:id])
    if @campaign.campaign_status == 2
      flash[:error] = "活动已结束，不能修改或删除"
      redirect_to "/campaigns"
    end
  end

end
