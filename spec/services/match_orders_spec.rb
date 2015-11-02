require 'rails_helper'

RSpec.describe MatchOrders, kind: :service do
  let(:stock) { create(:stock) }
  let(:user) { create(:user) }

  # There are a lot of ways that I could use context, describe and it
  # to describe behaviour.

  context 'a buy order matches against existing sell orders' do
    it 'gets fulfilled' do
      sell1 = user.orders.sell.create!(stock: stock, quantity: 100, price: 4)
      sell2 = user.orders.sell.create!(stock: stock, quantity: 100, price: 1)
      buy1 = user.orders.buy.create!(stock: stock, quantity: 100, price: 3)

      MatchOrders.new(stock: stock).call

      expect(sell1.reload).to_not be_fulfilled
      expect(sell2.reload).to be_fulfilled
      expect(buy1.reload).to be_fulfilled
    end
  end

  context 'a sell order matches against exsting buy orders' do
    it 'gets fulfilled' do
      buy1 = user.orders.buy.create!(stock: stock, quantity: 100, price: 3)
      buy2 = user.orders.buy.create!(stock: stock, quantity: 100, price: 2)
      sell1 =  user.orders.sell.create!(stock: stock, quantity: 100, price: 3)

      MatchOrders.new(stock: stock).call

      expect(buy1.reload).to be_fulfilled
      expect(buy2.reload).to_not be_fulfilled
      expect(sell1.reload).to be_fulfilled
    end
  end

  context 'a buy order matches against the most oldest matching sell order' do
    it 'gets fulfilled' do
      sell1 = user.orders.sell.create!(stock: stock, quantity: 100, price: 3)
      sell2 = user.orders.sell.create!(stock: stock, quantity: 100, price: 3, created_at: 1.day.ago)
      buy1 = user.orders.buy.create!(stock: stock, quantity: 100, price: 3)

      MatchOrders.new(stock: stock).call

      expect(sell1.reload).to_not be_fulfilled
      expect(sell2.reload).to be_fulfilled
      expect(buy1.reload).to be_fulfilled
    end
  end

  context 'a sell order matches against the most oldest matching buy order' do
    it 'gets fulfilled' do
      buy1 = user.orders.buy.create!(stock: stock, quantity: 100, price: 3)
      buy2 = user.orders.buy.create!(stock: stock, quantity: 100, price: 3, created_at: 1.day.ago)
      sell1 = user.orders.sell.create!(stock: stock, quantity: 100, price: 3)

      MatchOrders.new(stock: stock).call

      expect(buy1.reload).to_not be_fulfilled
      expect(buy2.reload).to be_fulfilled
      expect(sell1.reload).to be_fulfilled
    end
  end

  context 'empty orders matching' do
    it 'does nothing when there are no sell orders' do
      buy1 = user.orders.buy.create!(stock: stock, quantity: 100, price: 3)
      buy2 = user.orders.buy.create!(stock: stock, quantity: 100, price: 3)

      MatchOrders.new(stock: stock).call

      expect(buy1.reload).to_not be_fulfilled
      expect(buy2.reload).to_not be_fulfilled
    end

    it 'does nothing when there are no buy orders' do
      sell1 = user.orders.sell.create!(stock: stock, quantity: 100, price: 3)
      sell2 = user.orders.sell.create!(stock: stock, quantity: 100, price: 3)

      MatchOrders.new(stock: stock).call

      expect(sell1.reload).to_not be_fulfilled
      expect(sell2.reload).to_not be_fulfilled
    end
  end

  context "fulfilled orders, aren't counted twice" do
    it 'picks an unfulfilled sell order' do
      sell1 = user.orders.sell.create!(stock: stock, quantity: 100, price: 3, fulfilled_at: Time.now)
      sell2 = user.orders.sell.create!(stock: stock, quantity: 100, price: 3)
      buy1 = user.orders.buy.create!(stock: stock, quantity: 100, price: 3)

      MatchOrders.new(stock: stock).call

      expect(sell1.reload).to be_fulfilled
      expect(sell2.reload).to be_fulfilled
      expect(buy1.reload).to be_fulfilled

    end

    it 'picks an unfulfilled buy order' do
      buy1 = user.orders.buy.create!(stock: stock, quantity: 100, price: 2, fulfilled_at: Time.now)
      buy2 = user.orders.buy.create!(stock: stock, quantity: 100, price: 2)
      sell1 =  user.orders.sell.create!(stock: stock, quantity: 100, price: 2)

      MatchOrders.new(stock: stock).call

      expect(buy1.reload).to be_fulfilled
      expect(buy2.reload).to be_fulfilled
      expect(sell1.reload).to be_fulfilled
    end
  end
end
