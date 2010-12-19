class TransferLineItem < ActiveRecord::Base
  belongs_to :material
  belongs_to :salesrep
  belongs_to :region
  belongs_to :warehouse
  belongs_to :transfer
  
  validates_numericality_of :quantity
  validates_numericality_of :unit_price,:greater_than=>0

end
