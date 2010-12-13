class MaterialsController < ApplicationController
  before_filter :login_required
  
  access_control do
    allow :pm
  end
  
  def index
    material = Material
    material = material.in_state("activated")
    @materials = material.paginate(:all,:per_page=>20,:page => params[:page], :order => 'materials.created_at DESC')
  end
  
  def new
    @material = Material.new
  end
  
  def create
    @material = Material.new(params[:material])
    if @material.save
      redirect_to "/materials"
      flash[:notice] = "物料#{@material.name}添加成功"
    else
      flash[:error]  = "添加失败，请重新尝试"
      render :action => 'new'
    end
  end
  
  def edit
    @material = Material.find(params[:id])
  end
  
  def update
    @material = Material.find(params[:id])
    if @material.update_attributes(params[:material])
      flash[:notice] = "#{@material.name} 修改成功"
      redirect_to "/materials"
    else
      flash[:error] = "#{@material.name} 修改失败"
      render :action => "edit"
    end
  end
  
  def destroy
    @material = Material.find(params[:id])
    if @material.delete_material!
      flash[:notice] = "#{@material.name} 删除成功"
    else
      flash[:error] = "发生未知错误，请联系管理员"
    end
    redirect_to "/materials"
  end
  
end
