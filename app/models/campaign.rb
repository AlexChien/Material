class Campaign < ActiveRecord::Base
  has_many :catalogs
  has_many :orders
  has_many :productions
end
