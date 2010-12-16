class SalesrepsController < ApplicationController
  before_filter :login_required
  before_filter :filter_region,:only=>[:edit,:update,:destroy]

  access_control do
    allow :rc
  end

  def index
    salesrep = Salesrep
    salesrep = salesrep.in_state("activated")
    salesrep = salesrep.in_region(current_user.region)
    @salesreps = salesrep.paginate(:all,:per_page=>20,:page => params[:page], :order => 'salesreps.created_at DESC')
  end

  def new
    @salesrep = Salesrep.new
  end

  def create
    @salesrep = Salesrep.new(params[:salesrep])
    if @salesrep.save
      redirect_to "/salesreps"
      flash[:notice] = "物料#{@salesrep.name}添加成功"
    else
      flash[:error]  = "添加失败，请重新尝试"
      render :action => 'new'
    end
  end

  def edit

  end

  def update
    if @salesrep.update_attributes(params[:salesrep])
      flash[:notice] = "#{@salesrep.name} 修改成功"
      redirect_to "/salesreps"
    else
      flash[:error] = "#{@salesrep.name} 修改失败"
      render :action => "edit"
    end
  end

  def destroy
    if @salesrep.delete_salesrep!
      flash[:notice] = "#{@salesrep.name} 删除成功"
    else
      flash[:error] = "发生未知错误，请联系管理员"
    end
    redirect_to "/salesreps"
  end

protected
  def filter_region
    @salesrep = Salesrep.find(params[:id])
    if current_user.region != @salesrep.region
      flash[:error] = "您没有权限修改此销售"
      redirect_to "/salesreps"
    end
  end

end
