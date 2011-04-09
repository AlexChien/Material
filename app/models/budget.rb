class Budget < ActiveRecord::Base
  belongs_to :campaign
  belongs_to :region
end
