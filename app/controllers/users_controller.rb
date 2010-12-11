class UsersController < ApplicationController

  before_filter :login_required

  access_control do
    allow :admin
  end
  
  def index
  end

  # render new.rhtml
  def new
    @user = User.new
  end

  def create
    # logout_keeping_session!
    @user = User.new(params[:user])
    success = @user && @user.save
    if success && @user.errors.empty?
      # Protects against session fixation attacks, causes request forgery
      # protection if visitor resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset session
      # self.current_user = @user # !! now logged in
      redirect_to "/users"
      flash[:notice] = "添加用户成功"
    else
      flash[:error]  = "添加失败，请重新尝试"
      render :action => 'new'
    end
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
