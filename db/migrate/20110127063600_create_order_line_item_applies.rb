class CreateOrderLineItemApplies < ActiveRecord::Migration
  def self.up
    create_table :order_line_item_applies do |t|
      t.integer :order_line_item_raw_id
      t.integer :status, :default=>0
      t.integer :apply_quantity, :default=>0
      t.decimal :apply_subtotal, :precision => 8, :scale => 2, :default => 0
      t.string :address
      t.string :memo
      t.timestamps
    end

    add_column :order_line_item_raws, :apply_size, :integer, :default=>0
    add_column :order_line_item_raws, :applied_size, :integer, :default=>0
    add_column :order_line_item_raws, :sended_size, :integer, :default=>0

    OrderLineItemRaw.all(:conditions=>["status > 1"]).each do |olir|
      OrderLineItemApply.create(:order_line_item_raw=>olir,
                                :status=>olir.status,
                                :apply_quantity=>olir.quantity,
                                :apply_subtotal=>olir.subtotal,
                                :address=>olir.address,
                                :memo=>olir.memo)
    end
  end

  def self.down
    drop_table :order_line_item_applies

    remove_column :order_line_item_raws, :apply_size
    remove_column :order_line_item_raws, :applied_size
    remove_column :order_line_item_raws, :sended_size
  end
end
