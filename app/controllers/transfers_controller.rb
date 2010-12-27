class TransfersController < ApplicationController
  before_filter :login_required

  access_control do
    allow :wa
  end

  def new
    @transfer = Transfer.new
    @transfer.transfer_line_items.build
    if params[:type]=="1"
      #总库入库
      render :template=>"transfers/new"
    elsif params[:type]=="2_3"
      #转移库存
      render :template=>"transfers/transfer"
    end
  end

  def create
    tr_id = params[:transfer][:transfer_type_id]
    @transfer = Transfer.new(params[:transfer])
    #总库入库
    if tr_id == "1"
      @material = @transfer.transfer_line_items.first.material
      if @transfer.save
        flash[:notice] = "物料#{@material.name}入库成功"
        redirect_to "/inventories?is_central=1"
      else
        flash[:error] = "物料#{@material.name}入库失败，请重新尝试"
        render :action => "new"
      end
    elsif tr_id == "2" || tr_id == "3"
        tli = @transfer.transfer_line_items.first
        @material = tli.material
        i_m = Inventory.in_warehouse(Warehouse.in_central(true).first).in_material(@material.id).first
        quantity = i_m.nil? ? 0 : i_m.quantity
        if quantity < tli.quantity
          flash[:error] = "库存量不足，不能转移"
          redirect_to "/inventories?is_central=1"
          return
        end
        Transfer.transaction do
        if @transfer.save
          params = {:from_region_id=>@transfer.to_region_id,
                    :to_region_id=>@transfer.from_region_id,
                    :from_warehouse_id=>@transfer.to_warehouse_id,
                    :to_warehouse_id=>@transfer.from_warehouse_id,
                    :transfer_type_id=>@transfer.transfer_type_id,
                    :memo=>@transfer.memo,
                    :transfer_line_items_attributes=>{"0"=>{"material_id"=>"#{@material.id}",
                                                            "quantity"=>"-#{tli.quantity}",
                                                            "unit_price"=>"#{tli.unit_price}",
                                                            "subtotal"=>"-#{tli.subtotal}",
                                                            "region_id"=>"#{@transfer.from_region_id}",
                                                            "warehouse_id"=>"#{@transfer.from_warehouse_id}"}}
                    }
          Transfer.new(params).save#transfer创建一条相反的记录

          #检查物料是否全部送达，来更新订单状态
          olia = OrderLineItemAdjusted.in_material(@material.id).in_region(@transfer.to_region.id).is_arrived(0).first
          unless olia.nil?
            i = Inventory.in_region(@transfer.to_region.id).in_material(@material.id).first
            olia.update_attribute(:arrived,1) if i.quantity >= olia.quantity_total
            olia.order.update_attribute(:order_status_id,6) if OrderLineItemAdjusted.in_order(olia.order.id).is_arrived(0).empty?
          end

          flash[:notice] = "物料#{@material.name}转移成功"
          redirect_to "/inventories?is_central=0"
        else
          flash[:error] = "物料#{@material.name}转移失败，请重新尝试"
          render :action => "new"
        end
      end
    end
  end

end
