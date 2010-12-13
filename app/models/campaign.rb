class Campaign < ActiveRecord::Base
  has_many :catalogs
  has_many :orders
  has_many :productions
  
  validates_presence_of :name
  
  named_scope :in_state, lambda {|state|
        {:conditions => ["campaigns.state = ?", state]}
  }
  
  state_machine :initial => :activated do
    event :delete_campaign  do transition all => :deleted end
  end
end
