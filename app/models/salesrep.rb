class Salesrep < ActiveRecord::Base
  belongs_to :region
  has_many :transfer_line_items
end
