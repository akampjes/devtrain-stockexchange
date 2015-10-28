class RefactorFillsStructure < ActiveRecord::Migration
  def change
    remove_column :fills, :order_id
    remove_column :fills, :matched_order_id

    add_column :fills, :buy_order_id, :integer
    add_column :fills, :sell_order_id, :integer
    add_index :fills, :buy_order_id
    add_index :fills, :sell_order_id
  end
end
