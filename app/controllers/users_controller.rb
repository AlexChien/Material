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
    if User.authenticate(@user.login, params[:old_password])
      if ((params[:user][:password] == params[:user][:password_confirmation]) && !params[:user][:password_confirmation].blank?)
        @user.password_confirmation = params[:user][:password_confirmation]
        @user.password = params[:user][:password]
        begin
          if @user.save
            flash[:notice] = '密码已修改.'
            redirect_to('/dashboard')
          else
            flash[:error] = '密码修改出错，请重试.'
            redirect_to('/users/change_password_form')
          end
        rescue  => e
          render :text => e
        end
      else
        flash[:error] = '确认密码输入错误.'
        redirect_to('/users/change_password_form')
      end
    else
      flash[:error] = '当前密码输入错误.'
      redirect_to('/users/change_password_form')
    end
  end

end
