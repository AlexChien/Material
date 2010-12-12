class OrderLineItemAdjusted < ActiveRecord::Base
  belongs_to :order
  belongs_to :region
  belongs_to :material
end
