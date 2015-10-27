class RenameFurfilledToFilfilledOnOrders < ActiveRecord::Migration
  def change
    rename_column :orders, :furfilled, :fulfilled
  end
end
