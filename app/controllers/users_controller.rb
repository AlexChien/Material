class UsersController < ApplicationController

  before_filter :login_required

  access_control do
    allow :admin
  end

  # render new.rhtml
  def new
    @user = User.new
  end

  def create
    logout_keeping_session!
    @user = User.new(params[:user])
    success = @user && @user.save
    if success && @user.errors.empty?
      # Protects against session fixation attacks, causes request forgery
      # protection if visitor resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset session
      self.current_user = @user # !! now logged in
      redirect_back_or_default('/')
      flash[:notice] = "Thanks for signing up!  We're sending you an email with your activation code."
    else
      flash[:error]  = "We couldn't set up that account, sorry.  Please try again, or contact an admin (link is above)."
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
