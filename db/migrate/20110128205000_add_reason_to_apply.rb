class AddReasonToApply < ActiveRecord::Migration
  def self.up
    add_column :order_line_item_applies, :reason, :text
  end

  def self.down
    remove_column :order_line_item_applies, :reason
  end
end
