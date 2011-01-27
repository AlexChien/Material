class DashboardController < ApplicationController
  before_filter :login_required

  def index
    if current_user.has_role?("admin") || current_user.has_role?("pm")
      admin_dashboard
    elsif current_user.has_role?("rc")
      rc_dashboard
    elsif current_user.has_role?("rm")
      rm_dashboard
    elsif current_user.has_role?("wa")
      wa_dashboard
    end
  end

  def admin_dashboard
    @regions = Region.in_central(false).all
    @assigned_budget_0 = Region.in_central(false).assigned_budget_0.count
    @orders = Order.in_region(current_user.region).in_order_status(3).all
    render :template => "dashboard/pm_index"
  end

  def rc_dashboard
    @catalogs = Catalog.starting(true).all
    @orders = Order.in_region(current_user.region).in_order_status(2).all
    @olirs = OrderLineItemRaw.in_region(current_user.region).in_status(1).all
    @olias = OrderLineItemApply.in_region(current_user.region).in_status(4).all
    render :template => "dashboard/rc_index"
  end

  def rm_dashboard
    @orders = Order.in_region(current_user.region).in_order_status(1).all
    @order4s = Order.in_region(current_user.region).in_order_status(4).all
    @olias = OrderLineItemApply.in_region(current_user.region).in_status(2).all
    render :template => "dashboard/rm_index"
  end

  def wa_dashboard
    @olias = OrderLineItemApply.in_region(current_user.region).in_status(3).all
    render :template => "dashboard/wa_index"
  end

end
