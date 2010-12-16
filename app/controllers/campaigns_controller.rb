class CampaignsController < ApplicationController
  before_filter :login_required

  access_control do
    action :index do
      allow :pm,:rc
    end
    action :new, :create, :edit, :update, :destroy do
      allow :pm
    end
    action :book,:raw do
      allow :rc
    end
  end

  def index
    campaign = Campaign
    campaign = campaign.in_state("activated")
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
    @campaign = Campaign.find(params[:id])
  end

  def update
    @campaign = Campaign.find(params[:id])
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
    @campaign = Campaign.find(params[:id])
    if @campaign.delete_campaign!
      flash[:notice] = "#{@campaign.name} 删除成功"
    else
      flash[:error] = "发生未知错误，请联系管理员"
    end
    redirect_to "/campaigns"
  end
  
  def book
    @campaign = Campaign.find(params[:id])
    cm = CatalogsMaterial
    cm = cm.in_catalog(@campaign.campaign_catalog.id)
    @cms = cm.all(:order=>"created_at DESC")
    olir = OrderLineItemRaw
    olir = olir.in_catalog(@campaign.campaign_catalog.id)
    @olirs = olir.all(:order=>"created_at DESC")
    salesrep = Salesrep
    salesrep = salesrep.in_state("activated")
    salesrep = salesrep.in_region(current_user.region)
    @salesreps = salesrep.all(:order=>"created_at DESC")
  end
  
  def raw
    @campaign = Campaign.find(params[:id])
    num = params[:num].to_i
    @material = Material.find(params[:material_id])
    @cm = CatalogsMaterial.in_catalog(@campaign.campaign_catalog.id).in_material(@material.id).first
    check(num,params[:salesrep_id])
    if @error_message.nil?
      salesrep = Salesrep.find(params[:salesrep_id])
      exist_olir = OrderLineItemRaw.in_catalog(@campaign.campaign_catalog.id).in_salesrep(salesrep.id).in_material(@material.id).first
      if exist_olir.nil?
        OrderLineItemRaw.create(:campaign=>@campaign,
                                :catalog=>@campaign.campaign_catalog,
                                :material=>@material,
                                :region=>current_user.region,
                                :quantity=>num,
                                :unit_price=>@cm.price,
                                :subtotal=>num * @cm.price,
                                :salesrep=>salesrep)
      else
        exist_olir.update_attributes(:quantity=>exist_olir.quantity+num,:subtotal=>exist_olir.subtotal+num * @cm.price)
      end
    end
    olir = OrderLineItemRaw
    olir = olir.in_catalog(@campaign.campaign_catalog.id)
    @olirs = olir.all(:order=>"created_at DESC")
    render :partial => "order_list"
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

end
