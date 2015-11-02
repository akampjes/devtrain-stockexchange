class AddMoneyToUsers < ActiveRecord::Migration
  def change
    add_column :users, :money, :integer
  end
end
