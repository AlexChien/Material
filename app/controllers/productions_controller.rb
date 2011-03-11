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

  def generate_excel
    @production = Production.find(params[:id])
    if @production.locked
      book = Spreadsheet::Workbook.new
      sheet = book.create_worksheet :name => "production_#{@production.id}"
      if params[:type] == "detail"
        concat = ['sku',
          '物料名称',
          '所属大区',
          '预定数量']
        sheet.row(0).concat(concat)
        order_ids = []
        Order.in_catalog(@production.catalog).each do |order|
          order_ids << order.id
        end
        @olias = OrderLineItemAdjusted.in_order(order_ids).all(:include=>[:material])
        @olias.each_with_index do |record,index|
          replace = [record.material.sku,
            record.material.name,
            record.region.name,
            record.quantity_total.to_f
            ]
          sheet.row(index+1).replace(replace)
        end
      else
        concat = ['sku',
          '物料名称',
          '预定数量',
          '调整数量',
          '预定总数']
        sheet.row(0).concat(concat)
        @plis = @production.production_line_items.all(:include=>[:material])
        @plis.each_with_index do |record,index|
          replace = [record.material.sku,
            record.material.name,
            record.quantity_collected.to_f,
            record.quantity_adjusted.to_f,
            record.quantity_total.to_f,
            ]
          sheet.row(index+1).replace(replace)
        end
      end
      filename = "#{RAILS_ROOT}/tmp/tmp_xls/production_#{Time.now.to_i}.xls"
      book.write filename
      send_file filename
    else
      render :text => "该生产单不能导出"
    end
  end

  def load_data
    @production = Production.find(params[:id])
    # params[:filter].each do |index,f|
    #   puts params[:filter][index.to_s]["field"]
    #   puts params[:filter][index.to_s]["data"]["value"]
    # end
    if params[:type] == "detail"
      order_ids = []
      Order.in_catalog(@production.catalog).each do |order|
        order_ids << order.id
      end
      @olias = OrderLineItemAdjusted.in_order(order_ids).all(:include=>[:material])
      return_data = Hash.new()
      return_data[:size] = @olias.size
      return_data[:Olias] = @olias.collect{|p| {:id=>p.id,
                                              :sku=>p.material.sku,
                                              :name=>p.material.name,
                                              :region=>p.region.name,
                                              :quantity_total=>p.quantity_total,
                                              :material_id=>p.material_id,
                                              }}
    else
      @plis = @production.production_line_items.all(:include=>[:material])
      return_data = Hash.new()
      return_data[:size] = @plis.size
      return_data[:Plis] = @plis.collect{|p| {:id=>p.id,
                                              :sku=>p.material.sku,
                                              :name=>p.material.name,
                                              :quantity_collected=>p.quantity_collected,
                                              :quantity_adjusted=>p.quantity_adjusted,
                                              :quantity_total=>p.quantity_total,
                                              :material_id=>p.material_id,
                                              }}
    end
    render :text=>return_data.to_json, :layout=>false
  end

end