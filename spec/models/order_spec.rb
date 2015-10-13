require 'rails_helper'

# this is where i include factorygirl
RSpec.describe Order, kind: :model do
  let(:stock) { Stock.create!(name: 'stockname', symbol: 'stocksym') }

  it 'is valid' do
    order = Order.new(stock: stock, price: 1, quantity: 1, kind: :buy)
    expect(order).to be_valid
  end

  context 'there are buy and sell orders' do
  end

  describe 'invalid orders' do
    it 'requires a kind' do
      order = Order.new(stock: stock, price: 1, quantity: 1)
      expect(order).to be_invalid
    end

    it 'requires a stock' do
      order = Order.new(kind: :buy, price: 1, quantity: 1)
      expect(order).to be_invalid
    end
  end
end
