# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
#  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  include AuthenticatedSystem

  rescue_from 'Acl9::AccessDenied', :with => :access_denied
  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

private

  def access_denied
    flash[:error] = '你没有登陆或者没有权限执行此操作。'
    redirect_to login_path
  end

end
