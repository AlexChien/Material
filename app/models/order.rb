class Order < ActiveRecord::Base
  belongs_to :catalog
  belongs_to :campaign
  belongs_to :region
  has_many :order_statuses
  has_many :order_line_item_raws
  has_many :order_line_item_adjusteds
end
