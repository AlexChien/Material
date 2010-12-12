class UsersController < ApplicationController

  before_filter :login_required

  access_control do
    allow :admin
    action :change_password_form, :change_password do
      allow logged_in
    end
  end
  
  def index
    user = User
    user = user.include_admin(false)
    user = user.in_region(params[:region_id]) unless params[:region_id].blank?
    user = user.in_role(params[:role_id]) unless params[:role_id].blank?
    @users = user.paginate(:all,:include=>[:region],:per_page=>20,:page => params[:page], :order => 'users.created_at DESC')
  end

  # render new.rhtml
  def new
    @user = User.new
  end

  def create
    # logout_keeping_session!
    @user = User.new(params[:user])
    if @user.save
      redirect_to "/users"
      flash[:notice] = "添加用户成功"
    else
      flash[:error]  = "添加失败，请重新尝试"
      render :action => 'new'
    end
  end
  
  def edit
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:notice] = "#{@user.login} 修改成功"
      redirect_to "/users"
    else
      flash[:error] = "#{@user.login} 修改失败"
      render :action => "edit"
    end
  end
  
  def destroy
    @user = User.find(params[:id])
    if @user.destroy
      flash[:notice] = "#{@user.login} 删除成功"
    else
      flash[:error] = "发生未知错误，请通知管理员"
    end
    redirect_to "/users"
  end

  def change_password_form
    @user = current_user
  end

  def change_password
    @user = current_user
    if @user.update_attributes(params[:user])
      flash[:notice] = "密码修改成功"
      redirect_to "/dashboard"
    else
      render :action => "change_password_form"
    end
  end

end
