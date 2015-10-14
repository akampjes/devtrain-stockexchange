require 'rails_helper'

RSpec.feature "Orders", type: :feature do
  scenario 'Place on order' do
    visit orders_path

    click_on 'New Order'

    expect(current_path).to eq new_order_path
    fill_in 'kind', with: 'buy'
    fill_in 'price', with: 1
    fill_in 'quantity', with: 1
    stock = Stock.first
    select stock.symbol from: 'stock'
    click_on 'Create order'

    expect(current_path).to eq orders_path
  end
end
