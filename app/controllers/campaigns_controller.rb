class CampaignsController < ApplicationController
  before_filter :login_required
  
  access_control do
    allow :pm
  end
  
  def index
    campaign = Campaign
    campaign = campaign.in_state("activated")
    @campaigns = campaign.paginate(:all,:per_page=>20,:page => params[:page], :order => 'campaigns.created_at DESC')
  end
  
  def new
    @campaign = Campaign.new
    @campaign.catalogs.build
  end
  
  def create
    @campaign = Campaign.new(params[:campaign])
    if @campaign.save
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

end
