class ProductionsController < ApplicationController
  before_filter :login_required

  access_control do
    allow :pm,:admin
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

  def print
    @production = Production.find(params[:id])
    if @production.locked
      render :layout => "print"
    else
      render :text => "该生产单不能打印"
    end
  end

end
