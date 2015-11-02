require 'rails_helper'

RSpec.describe Fill, type: :model do
  let(:user) { create(:user) }
  let(:stock) { create(:stock) }
  let(:buy_order) { create(:buy_order, stock: stock, user: user) }
  let(:sell_order) { create(:sell_order, stock: stock, user: user) }

  it 'has both an order and a matched_order' do
    fill = Fill.new(buy_order: buy_order, sell_order: sell_order)


    expect(fill.buy_order).to eq buy_order
    expect(fill.sell_order).to eq sell_order
  end
end
