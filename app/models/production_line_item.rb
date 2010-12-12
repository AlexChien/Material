class ProductionLineItem < ActiveRecord::Base
  belongs_to :material
  belongs_to :production
end
