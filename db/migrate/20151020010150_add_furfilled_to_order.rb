class AddFurfilledToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :furfilled, :boolean
  end
end
