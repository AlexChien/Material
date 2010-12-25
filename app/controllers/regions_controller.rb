class RegionsController < ApplicationController
  before_filter :login_required

  access_control do
    allow :pm,:admin
  end

  def index
    region = Region
    @regions = region.paginate(:all,:per_page=>20,:page => params[:page], :order => 'regions.created_at DESC')
  end

  def edit
    @region = Region.find(params[:id])
  end

  def update
    @region = Region.find(params[:id])
    if @region.update_attributes(params[:region])
      flash[:notice] = "#{@region.name} 修改成功"
      redirect_to "/regions"
    else
      flash[:error] = "#{@region.name} 修改失败"
      render :action => "edit"
    end
  end

end
