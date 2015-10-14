require 'rails_helper'

RSpec.feature "Orders", type: :feature do
  before do
    stock = create(:stock)
    user = create(:user)
    login_as(user, :scope => :user)
  end

  scenario 'Place on order' do
    visit orders_path

    click_on 'New Order'

    expect(current_path).to eq new_order_path
    fill_in 'Kind', with: 'buy'
    fill_in 'Price', with: 1
    fill_in 'Quantity', with: 1
    stock = Stock.first
    select stock.name, from: 'Stock'
    click_on 'Create Order'

    expect(current_path).to eq orders_path
  end
end
