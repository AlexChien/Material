class Production < ActiveRecord::Base
  has_many :production_line_items
  belongs_to :campaign
  belongs_to :catalog
end
