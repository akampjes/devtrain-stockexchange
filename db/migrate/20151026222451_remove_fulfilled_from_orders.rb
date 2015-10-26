class RemoveFulfilledFromOrders < ActiveRecord::Migration
  def change
    remove_column :orders, :fulfilled
  end
end
