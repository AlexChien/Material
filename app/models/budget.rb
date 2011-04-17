class Budget < ActiveRecord::Base
  belongs_to :campaign
  belongs_to :region
  
  named_scope :in_region, lambda {|region|
        {:conditions => ["budgets.region_id = ?", region]}
  }

  named_scope :in_campaign, lambda {|campaign|
        {:conditions => ["budgets.campaign_id = ?", campaign]}
  }
  
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
  
end
