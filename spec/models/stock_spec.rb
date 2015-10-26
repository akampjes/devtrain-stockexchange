require 'rails_helper'

RSpec.describe Stock, type: :model do
  it 'is valid with a name and symbol' do
    subject.name = 'testname'
    subject.symbol = 'test'
  end

  context 'invalid conditions' do
    it 'is invalid without a name and symbol' do
      expect(subject).to be_invalid
    end
  end

  context 'may have a market price' do
    it 'has had no orders' do
      expect(subject.market_price).to be_nil
    end

    it 'has an order' do
      order = create(:buy_order, fulfilled_at: Time.now)

      expect(order.stock.market_price).to eq order.price
    end

    it 'is the most recent fulfilled order price' do
      stock = create(:stock)
      user = create(:user)
      create(:buy_order, stock: stock, user: user, fulfilled_at: Time.now)
      order = create(:sell_order, stock: stock, user: user, fulfilled_at: Time.now, price: 1337)

      expect(order.stock.market_price).to eq order.price
    end
  end
end
