class Region < ActiveRecord::Base
  has_many :users
  has_many :salesreps
  has_many :orders
  has_many :order_line_item_raws
  has_many :order_line_item_adjusteds
  has_many :inventories
  has_one :warehouse
  has_many :transfer_line_items
  has_many :to_transfers, :class_name => 'Transfer', :foreign_key => 'to_region_id'
  has_many :from_transfers, :class_name => 'Transfer', :foreign_key => 'from_region_id'

  validates_numericality_of :assigned_budget,:greater_than_or_equal_to=>0
  validate :assigned_budget_check,:assigned_budget

  named_scope :in_central, lambda {|boolean|
    if boolean
      {:conditions => ["regions.is_central = 1"]}
    else
      {:conditions => ["regions.is_central = 0"]}
    end
  }

  named_scope :in_id, lambda {|id|
        {:conditions => ["regions.id in (?)", id]}
  }

  named_scope :assigned_budget_0, {:conditions => ["regions.assigned_budget = 0"]}

  before_update :observer_assigned_budget

  def observer_assigned_budget
    if assigned_budget_changed?
      self.redeemable_budget = self.assigned_budget - self.used_budget
    end
    if used_budget_changed?
      self.redeemable_budget = self.assigned_budget - self.used_budget
    end
  end

  def percent
    if self.assigned_budget == 0
      0
    else
      (self.used_budget/self.assigned_budget*100).round
    end
  end

  def percent_image
    p = percent
    if p > 75
      "/images/powerposm/progressbar/progressbg_red.gif"
    elsif p > 50 && p <= 75
      "/images/powerposm/progressbar/progressbg_orange.gif"
    elsif p > 25 && p <= 50
      "/images/powerposm/progressbar/progressbg_yellow.gif"
    else
      "/images/powerposm/progressbar/progressbg_green.gif"
    end
  end

protected
  def assigned_budget_check
    if self.assigned_budget < self.used_budget
      errors.add(:assigned_budget, "预算已使用#{self.used_budget}，分配预算不能小于已使用预算！")
    end
  end

end
