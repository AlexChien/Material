class ProductionsController < ApplicationController
  before_filter :login_required
  
  access_control do
    allow :pm
  end
  
  def show
    @production = Production.find(params[:id])
  end
  
  def update
    @production = Production.find(params[:id])
    @production.update_attribute(:locked,true)
    flash[:notice] = "生产单已锁定！"
    redirect_to "/productions/#{@production.id}"
  end
  
end
