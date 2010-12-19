class TransfersController < ApplicationController
  before_filter :login_required
  
  access_control do
    allow :wa
  end
  
  def new
    @transfer = Transfer.new
    @transfer.transfer_line_items.build
  end
  
  #总库入库
  def create
    @transfer = Transfer.new(params[:transfer])
    @material = @transfer.transfer_line_items.first.material
    @transfer.transfer_type = TransferType.find(1)
    if @transfer.save
      flash[:notice] = "物料#{@material.name}入库成功"
      redirect_to "/inventories"
    else
      flash[:error] = "物料#{@material.name}入库失败，请重新尝试"
      render :action => "new"
    end
  end
  
end
