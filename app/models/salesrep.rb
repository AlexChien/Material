class Salesrep < ActiveRecord::Base
  belongs_to :region
  has_many :transfer_line_items
  has_many :order_line_item_raws
  has_many :order_line_item_applies

  validates_presence_of :name, :address

  named_scope :in_region, lambda {|region_id|
        {:conditions => ["salesreps.region_id in (?)", region_id]}
  }

  named_scope :in_state, lambda {|state|
        {:conditions => ["salesreps.state = ?", state]}
  }

  state_machine :initial => :activated do
    event :delete_salesrep  do transition all => :deleted end
  end

  before_save :add_region

protected
  def add_region
    self.region = User.current_user.region
  end

end
