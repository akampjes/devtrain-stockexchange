require 'rails_helper'

RSpec.describe MatchOrders, kind: :service do
  let(:stock) { create(:stock) }
  let(:user) { create(:user) }

  it 'matches a buy order' do
    sell1 = Order.create!(stock: stock, user: user, kind: 'sell', quantity: 100, price: 3)
    sell2 = Order.create!(stock: stock, user: user, kind: 'sell', quantity: 100, price: 1)
    buy1 = Order.create!(stock: stock, user: user, kind: 'buy', quantity: 100, price: 3)

    MatchOrders.new.call

    expect(buy1.furfilled).to be_truthy
    expect(sell2.furfilled).to be_truthy
    expect(sell1.furfilled).to be_falsey
  end
end
