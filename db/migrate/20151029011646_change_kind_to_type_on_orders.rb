class ChangeKindToTypeOnOrders < ActiveRecord::Migration
  def change
    rename_column :orders, :kind, :type
  end
end
