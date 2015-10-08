class CreateStocks < ActiveRecord::Migration
  def change
    create_table :stocks do |t|
      t.text :name
      t.text :symbol

      t.timestamps null: false
    end
    add_index :stocks, :name, unique: true
    add_index :stocks, :symbol, unique: true
  end
end
