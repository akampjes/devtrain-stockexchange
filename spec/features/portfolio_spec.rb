require 'rails_helper'

RSpec.feature "Portfolio", type: :feature do
  scenario 'View my portfolio' do
    user = create(:user)
    login_as(user, :scope => :user)

    visit portfolio_index_path

    expect(page).to have_content "Hi #{user.email}"
    expect(page).to have_content "Current money: #{user.money}"
    expect(page).to have_content "Symbol Quantity Price Total value Change"
  end
end
