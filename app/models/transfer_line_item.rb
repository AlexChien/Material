class TransferLineItem < ActiveRecord::Base
  belongs_to :material
  belongs_to :salesrep
  belongs_to :region
  belongs_to :warehouse
end
