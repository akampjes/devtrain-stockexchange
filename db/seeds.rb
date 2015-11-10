# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
stock = Stock.create!(name: 'Spark New Zealand Ltd', symbol: 'SPK')
Stock.create!(name: 'Fletcher Building Ltd', symbol: 'FBU')
Stock.create!(name: 'Auckland Intl Airport Ltd', symbol: 'AIA')
Stock.create!(name: 'Fisher & Paykel Healthcare Corporation Limited', symbol: 'FPH')
Stock.create!(name: 'Contact Energy Ltd', symbol: 'CEN')
Stock.create!(name: 'Ryman Healthcare Group Ltd' , symbol: 'RYM')
Stock.create!(name: 'Meridian Energy Ltd', symbol: 'MEL')
Stock.create!(name: 'SkyCity Entertainment Group', symbol: 'SKC')
Stock.create!(name: 'Sky Network Television Limited', symbol: 'SKT')
Stock.create!(name: 'Infratil Ltd', symbol: 'IFT')

user = User.create!(email: 'admin@example.com', password: 'hunter01', password_confirmation: 'hunter01')

CreateOrder.new(order: user.sell_orders.new(stock: stock, quantity: 1337, price: 1)).call
CreateOrder.new(order: user.sell_orders.new(stock: stock, quantity: 100, price: 2)).call
CreateOrder.new(order: user.sell_orders.new(stock: stock, quantity: 50, price: 3)).call
