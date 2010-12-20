class TransferType < ActiveRecord::Base
  has_many :tranfers
  
  named_scope :in_id, lambda {|id|
        {:conditions => ["transfer_types.id in (?)", id]}
  }
end
