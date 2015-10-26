class AddFulfilledAtToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :fulfilled_at, :datetime
  end
end
