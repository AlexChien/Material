class CategoriesController < ApplicationController
  before_filter :login_required

  access_control do
    allow :pm,:admin
  end

  def index
    category = Category
    category = category.in_state("activated")
    @categories = category.paginate(:all,:per_page=>20,:page => params[:page], :order => 'categories.created_at DESC')
  end

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(params[:category])
    if @category.save
      redirect_to "/categories"
      flash[:notice] = "分类#{@category.name}添加成功"
    else
      flash[:error]  = "添加失败，请重新尝试"
      render :action => 'new'
    end
  end

  def edit
    @category = Category.find(params[:id])
  end

  def update
    @category = Category.find(params[:id])
    if @category.update_attributes(params[:category])
      flash[:notice] = "#{@category.name} 修改成功"
      redirect_to "/categories"
    else
      flash[:error] = "#{@category.name} 修改失败"
      render :action => "edit"
    end
  end

  def destroy
    @category = Category.find(params[:id])
    if @category.delete_category!
      flash[:notice] = "#{@category.name} 删除成功"
    else
      flash[:error] = "发生未知错误，请联系管理员"
    end
    redirect_to "/categories"
  end

  def sku
    text = ""
    unless params[:cid].blank?
      @category = Category.find(params[:cid])
      text = "sku：#{@category.cid}#{@category.next_sku}"
    end
    render :text => text
  end

end
