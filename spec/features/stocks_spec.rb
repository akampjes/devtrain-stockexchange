require 'rails_helper'

RSpec.feature "Stocks feature", type: :feature do
  let(:stock_name) { 'teststock' }
  let(:stock_symbol) { 'test' }
  scenario 'creating new stocks' do
    visit stocks_path
    click_on 'New Stock'

    fill_in 'Name', with: stock_name
    fill_in 'Symbol', with: stock_symbol
    click_on 'Create Stock'

    expect(page).to have_content "#{stock_name} (#{stock_symbol})"
  end

  scenario 'viewing existing stocks' do
    visit stocks_path
    stock = Stock.first

    expect(page).to have_content stock.name
    expect(page).to have_content stock.symbol
  end
end
