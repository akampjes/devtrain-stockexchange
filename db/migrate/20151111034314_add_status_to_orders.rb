class AddStatusToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :status, :text
    add_index :orders, :status
  end
end
