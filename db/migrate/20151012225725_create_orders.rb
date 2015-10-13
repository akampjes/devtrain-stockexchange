class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer :stock_id
      t.text :type
      t.integer :quantity
      t.integer :price

      t.timestamps null: false
    end
    add_index :orders, :stock_id
  end
end
