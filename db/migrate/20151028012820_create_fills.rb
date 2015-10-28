class CreateFills < ActiveRecord::Migration
  def change
    create_table :fills do |t|
      t.integer :order_id
      t.integer :matched_order_id
      t.text :kind
      t.integer :price
      t.integer :quantity

      t.timestamps null: false
    end
    add_index :fills, :order_id
    add_index :fills, :matched_order_id
  end
end
