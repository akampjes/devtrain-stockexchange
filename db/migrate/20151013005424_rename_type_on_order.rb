class RenameTypeOnOrder < ActiveRecord::Migration
  def change
    rename_column :orders, :type, :kind
  end
end
