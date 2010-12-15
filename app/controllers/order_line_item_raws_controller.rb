class OrderLineItemRawsController < ApplicationController
  before_filter :login_required

  access_control do
    allow :rc
  end
  
  def destroy
    @campaign = Campaign.find(params[:campaign_id])
    o = OrderLineItemRaw.find(params[:id])
    o.destroy
    olir = OrderLineItemRaw
    olir = olir.in_catalog(@campaign.campaign_catalog.id)
    @olirs = olir.all(:order=>"created_at DESC")
    render :partial => "campaigns/order_list"
  end
  
end
