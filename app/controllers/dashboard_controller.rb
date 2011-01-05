class DashboardController < ApplicationController
  before_filter :login_required

  def index
    if current_user.has_role?("admin") || current_user.has_role?("pm")
      admin_dashboard
    end
  end

  def admin_dashboard
    @regions = Region.in_central(false).all
    @assigned_budget_0 = Region.in_central(false).assigned_budget_0.count
    render :template => "dashboard/pm_index"
  end

end
