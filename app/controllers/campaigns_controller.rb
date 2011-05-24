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
      
      Region.in_central(false).all.each do |region|
        budget = params["budget_#{region.id}".to_sym].to_f
        overdraw = params["checkbox_budget_#{region.id}".to_sym].nil? ? 0 : params["checkbox_budget_#{region.id}".to_sym]
        b = Budget.new
        b.region =region
        b.campaign = @campaign
        b.assigned_budget = (budget >= 0 ? budget : 0)
        b.overdraw = overdraw
        b.save
      end

      # when PM creates campaign， which means a campaign is created and material catalog is registered， fire email to notify RM/RC about this campaign
      # Role.find_by_name("rc").users.each do |user|
      #   PosmMailer.deliver_onCampaignCreated(user,@campaign)
      # end
      # 
      # Role.find_by_name("rm").users.each do |user|
      #   PosmMailer.deliver_onCampaignCreated(user,@campaign)
      # end

      flash[:notice] = "活动#{@campaign.name}添加成功"
      redirect_to "/campaigns"
    else
      flash[:error]  = "添加失败，请重新尝试"
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    Region.in_central(false).all.each do |region|
      b = Budget.in_campaign(@campaign).in_region(region).first
      b = Budget.new if b.nil?
      budget = params["budget_#{region.id}".to_sym].to_f
      overdraw = params["checkbox_budget_#{region.id}".to_sym].nil? ? 0 : params["checkbox_budget_#{region.id}".to_sym]
      if budget < b.used_budget
        flash[:error] = "分配预算不能小于已使用预算！"
        render :action => "edit" and return
      else
        b.region =region
        b.campaign = @campaign
        b.assigned_budget = (budget >= 0 ? budget : 0)
        b.overdraw = overdraw
        b.save
      end
    end
    
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
    @cms = CatalogsMaterial.in_catalog(@campaign.campaign_catalog.id).all
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
                                # :apply_quantity=>num,
                                # :apply_subtotal=>num * @cm.price,
                                :salesrep=>salesrep)
      else
        exist_olir.update_attributes(:quantity=>exist_olir.quantity+num,:subtotal=>exist_olir.subtotal+num * @cm.price)
      end
    end
    @olirs = OrderLineItemRaw.in_catalog(@campaign.campaign_catalog.id).in_region(current_user.region.id).all(:order=>"created_at DESC")
    if false
      render :partial => "order_list"
    else
      render :partial => "ext_order_list"
    end
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
      olias = OrderLineItemAdjusted.in_order(order_ids).all(:select=>"sum(quantity_total) as qt,order_line_item_adjusteds.*",:group=>"material_id")
      Production.transaction do
        @production = Production.create(:campaign=>@campaign,:catalog=>@catalog)
        olias.each do |olia|
          ProductionLineItem.create(:production=>@production,
                                    :material=>olia.material,
                                    :quantity_collected=>olia.qt,
                                    :quantity_total=>olia.qt)
        end

        # when production sheet is created (cron job might be needed)
        Role.find_by_name("pm").users.each do |user|
          PosmMailer.deliver_onProductionSheetCreated(user,@campaign)
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
