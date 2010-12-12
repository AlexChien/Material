class Role < ActiveRecord::Base
  has_and_belongs_to_many :users
  
  named_scope :include_admin, lambda { |boolean|
    if boolean
    else
      {:conditions=>["roles.name != 'admin'"]}
    end
  }
end