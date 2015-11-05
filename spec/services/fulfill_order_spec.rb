require 'rails_helper'

RSpec.describe FulfillOrder, kind: :service do
  let (:stock) { create(:stock) }
  let (:buy_order) { create(:buy_order, stock: stock, user: create(:user), quantity: 100, price: 3) }
  let (:sell_order) { create(:sell_order, stock: stock, user: create(:user2), quantity: 100, price: 2) }

  subject { FulfillOrder.new(buy_order: buy_order, sell_order: sell_order) }

  it 'fulfills orders' do
    subject.call
    buy_order.reload
    sell_order.reload

    expect(buy_order).to be_fulfilled
    expect(sell_order).to be_fulfilled
  end

  it 'fulfills just the buy order with the correct quantity and price' do
    buy_order.update!(quantity: 50)

    subject.call

    fill = buy_order.fills.first
    expect(fill.quantity).to eq 50
    expect(fill.price).to eq 2

    expect(buy_order).to be_fulfilled
    expect(sell_order).to_not be_fulfilled
  end

  it 'fulfills just the sell order with the correct quantity and price' do
    sell_order.update!(quantity: 50)

    subject.call

    fill = sell_order.fills.first
    expect(fill.quantity).to eq 50
    expect(fill.price).to eq 2

    expect(buy_order).to_not be_fulfilled
    expect(sell_order).to be_fulfilled
  end

  # Test that money is transfered (the obvious side-effect of TransferMoneyForFill
  it 'transfers some money after fulfilling an order' do
    expect { subject.call }.to change {buy_order.user.money}
    expect { subject.call }.to change {sell_order.user.money}
  end
end
