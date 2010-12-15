# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
#  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  include AuthenticatedSystem

  rescue_from 'Acl9::AccessDenied', :with => :access_denied
  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
  before_filter :put_current_user_into_model

private

  # 给 User 添加 User.current_user 方法
  def put_current_user_into_model
    user = current_user
    if user
      User.current_user = user
    end
  end

  def access_denied
    flash[:error] = '你没有登陆或者没有权限执行此操作。'
    redirect_to login_path
  end

end
