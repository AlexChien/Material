class Category < ActiveRecord::Base
  has_many :materials

  validates_presence_of :cid,:name
  validates_uniqueness_of :cid,:name,:case_sensitive => false

  named_scope :in_state, lambda {|state|
        {:conditions => ["categories.state = ?", state]}
  }

  state_machine :initial => :activated do
    event :delete_category  do transition all => :deleted end
  end

end
