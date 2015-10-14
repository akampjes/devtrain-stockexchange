class AddUserToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :user_id, :integer
    add_index :orders, :user_id
  end
end
