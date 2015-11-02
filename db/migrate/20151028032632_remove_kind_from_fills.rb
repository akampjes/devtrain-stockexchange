class RemoveKindFromFills < ActiveRecord::Migration
  def change
    remove_column :fills, :kind
  end
end
