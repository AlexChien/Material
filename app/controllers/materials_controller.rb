class MaterialsController < ApplicationController
  before_filter :login_required
  
  access_control do
    allow :pm
  end
  
  def index
    material = Material
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
end
