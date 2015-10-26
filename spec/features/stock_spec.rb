require 'rails_helper'

RSpec.feature "Stocks", type: :feature do
  scenario 'Publically display stocks' do
    create(:stock)

    visit stocks_path
    expect(page).to have_content 'Symbol Name Price'
  end
end
