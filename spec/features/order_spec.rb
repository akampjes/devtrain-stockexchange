require 'rails_helper'

RSpec.feature "Orders", type: :feature do
  scenario 'Place an order' do
    stock = create(:stock)
    user = create(:user)
    login_as(user, :scope => :user)

    visit orders_path

    click_on 'New Order'

    expect(current_path).to eq new_order_path
    select 'BuyOrder', from: 'Type'
    fill_in 'Price', with: 1
    fill_in 'Quantity', with: 1
    stock = Stock.first
    select stock.name, from: 'Stock'
    click_on 'Create Order'

    expect(current_path).to eq orders_path
  end

  scenario 'Publically display orders' do
    order = create(:buy_order, quantity: 1337)

    visit stock_path(order.stock)
    expect(page).to have_content '1337'
  end
end
