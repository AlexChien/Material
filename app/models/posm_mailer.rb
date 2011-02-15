class PosmMailer < ActionMailer::Base
  layout "email"

  def onUserCreated(user)
    setup_email(user)
    @subject += '用户帐号建立'
    @body[:button_link] = "http://www.powerposm.com/"
    @body[:button_label] = "立即登录"
  end

  def onCampaignCreated(user,campaign)
    setup_email(user)
    @subject += "新活动 #{campaign.name} 即将开始"
    @body[:campaign] = campaign
    @body[:catalog] = campaign.catalogs.first
    if user.has_role?("rc")
      @body[:button_link] = "http://www.powerposm.com/campaigns/#{campaign.id}/book"
      @body[:button_label] = "预订物料"
    end
  end

  def onOrderSubmitted_RC2RM(user,order,rc)
    setup_email(user)
    @subject += "收到新的物料订单"
    @body[:order] = order
    @body[:rc] = rc
    @body[:button_link] = "http://www.powerposm.com/orders/#{order.id}"
    @body[:button_label] = "审核订单"
  end

  def onOrderRejected_RM2RC(user,order)
    setup_email(user)
    @subject += "物料订单 #{order.id} 被拒绝"
    @body[:order] = order
    @body[:button_link] = "http://www.powerposm.com/orders/#{order.id}"
    @body[:button_label] = "详细信息"
  end

  def onOrderApproved_byRM(user,order)
    setup_email(user)
    @subject += "物料订单 #{order.id} 通过区域审核"
    @body[:order] = order
    @body[:button_link] = "http://www.powerposm.com/orders/#{order.id}"
    @body[:button_label] = "详细信息"
  end

  def onOrderSubmitted_RM2PM(user,order,rm)
    setup_email(user)
    @subject += "收到新的区域物料订单 #{order.id}"
    @body[:order] = order
    @body[:rm] = rm
    @body[:button_link] = "http://www.powerposm.com/orders/#{order.id}"
    @body[:button_label] = "审核订单"
  end

  def onOrderRejected_PM2RM(user,order)
    setup_email(user)
    @subject += "物料订单 #{order.id} 被拒绝"
    @body[:order] = order
    @body[:button_link] = "http://www.powerposm.com/orders/#{order.id}"
    @body[:button_label] = "详细信息"
  end

  def onOrderApproved_byPM(user,order)
    setup_email(user)
    @subject += "物料订单 #{order.id} 通过审核"
    @body[:order] = order
    @body[:button_link] = "http://www.powerposm.com/orders/#{order.id}"
    @body[:button_label] = "详细信息"
  end

  def onProductionSheetCreated(user,campaign)
    setup_email(user)
    @subject += "活动 #{campaign.name} 预订结束，生产单已生成"
    @body[:campaign] = campaign
    @body[:button_link] = "http://www.powerposm.com/campaigns/#{campaign.id}/production"
    @body[:button_label] = "生产单"
  end

  def onStockIn(user,material,wa)
    setup_email(user)
    @subject += "新的物料入库 #{material.name}"
    @body[:material] = material
    @body[:wa] = wa
    @body[:button_link] = "http://www.powerposm.com/inventories?is_central=1"
    @body[:button_label] = "查看库存"
  end

  def onStockTransferred(user,material)
    setup_email(user)
    @subject += "物料转移入库 来自中央仓库"
    @body[:material] = material
    @body[:button_link] = "http://www.powerposm.com/inventories?is_central=0"
    @body[:button_label] = "查看库存"
  end

  def onStockRequestSubmitted_RC2RM
  end

  def onStockRequestApproved_byRM
  end

  def onStockRequestRejected_byRM
  end

  def onStockShipped
  end

  def onStockReceived
  end

protected
  def setup_email(user)
    @recipients  = "#{user.email}"
    @from        = "admin@powerposm.com"
    @subject     = "POSM - "
    @sent_on     = Time.now
    @body[:user] = user
    @body[:url] = "http://www.powerposm.com/"
  end
end
