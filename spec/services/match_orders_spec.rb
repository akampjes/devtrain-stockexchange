require 'rails_helper'

RSpec.describe MatchOrders, kind: :service do
  let(:stock) { create(:stock) }
  let(:user) { create(:user) }

  # There are a lot of ways that I could use context, describe and it
  # to describe behaviour.

  context 'a buy order matches against existing sell orders' do
    it 'gets fulfilled' do
      sell1 = user.sell_orders.create!(stock: stock, quantity: 100, price: 4)
      sell2 = user.sell_orders.create!(stock: stock, quantity: 100, price: 1)
      buy1 = user.buy_orders.create!(stock: stock, quantity: 100, price: 3)

      MatchOrders.new(stock: stock).call

      expect(sell1.reload).to_not be_fulfilled
      expect(sell2.reload).to be_fulfilled
      expect(buy1.reload).to be_fulfilled
    end
  end

  context 'a sell order matches against exsting buy orders' do
    it 'gets fulfilled' do
      buy1 = user.buy_orders.create!(stock: stock, quantity: 100, price: 3)
      buy2 = user.buy_orders.create!(stock: stock, quantity: 100, price: 2)
      sell1 =  user.sell_orders.create!(stock: stock, quantity: 100, price: 3)

      MatchOrders.new(stock: stock).call

      expect(buy1.reload).to be_fulfilled
      expect(buy2.reload).to_not be_fulfilled
      expect(sell1.reload).to be_fulfilled
    end
  end

  context 'a buy order matches against the most oldest matching sell order' do
    it 'gets fulfilled' do
      sell1 = user.sell_orders.create!(stock: stock, quantity: 100, price: 3)
      sell2 = user.sell_orders.create!(stock: stock, quantity: 100, price: 3, created_at: Time.now - 1.day)
      buy1 = user.buy_orders.create!(stock: stock, quantity: 100, price: 3)

      MatchOrders.new(stock: stock).call

      expect(sell1.reload).to_not be_fulfilled
      expect(sell2.reload).to be_fulfilled
      expect(buy1.reload).to be_fulfilled
    end
  end

  context 'a sell order matches against the most oldest matching buy order' do
    it 'gets fulfilled' do
      buy1 = user.buy_orders.create!(stock: stock, quantity: 100, price: 3)
      buy2 = user.buy_orders.create!(stock: stock, quantity: 100, price: 3, created_at: Time.now - 1.day)
      sell1 = user.sell_orders.create!(stock: stock, quantity: 100, price: 3)

      MatchOrders.new(stock: stock).call

      expect(buy1.reload).to_not be_fulfilled
      expect(buy2.reload).to be_fulfilled
      expect(sell1.reload).to be_fulfilled
    end
  end

  context 'empty orders matching' do
    it 'does nothing when there are no sell orders' do
      buy1 = user.buy_orders.create!(stock: stock, quantity: 100, price: 3)
      buy2 = user.buy_orders.create!(stock: stock, quantity: 100, price: 3)

      MatchOrders.new(stock: stock).call

      expect(buy1.reload).to_not be_fulfilled
      expect(buy2.reload).to_not be_fulfilled
    end

    it 'does nothing when there are no buy orders' do
      sell1 = user.sell_orders.create!(stock: stock, quantity: 100, price: 3)
      sell2 = user.sell_orders.create!(stock: stock, quantity: 100, price: 3)

      MatchOrders.new(stock: stock).call

      expect(sell1.reload).to_not be_fulfilled
      expect(sell2.reload).to_not be_fulfilled
    end
  end

  context "fulfilled orders, aren't counted twice" do
    it 'picks an unfulfilled sell order' do
      sell1 = user.sell_orders.create!(stock: stock, quantity: 100, price: 3, fulfilled_at: Time.now)
      sell2 = user.sell_orders.create!(stock: stock, quantity: 100, price: 3)
      buy1 = user.buy_orders.create!(stock: stock, quantity: 100, price: 3)

      MatchOrders.new(stock: stock).call

      expect(sell1.reload).to be_fulfilled
      expect(sell2.reload).to be_fulfilled
      expect(buy1.reload).to be_fulfilled

    end

    it 'picks an unfulfilled buy order' do
      buy1 = user.buy_orders.create!(stock: stock, quantity: 100, price: 2, fulfilled_at: Time.now)
      buy2 = user.buy_orders.create!(stock: stock, quantity: 100, price: 2)
      sell1 =  user.sell_orders.create!(stock: stock, quantity: 100, price: 2)

      MatchOrders.new(stock: stock).call

      expect(buy1.reload).to be_fulfilled
      expect(buy2.reload).to be_fulfilled
      expect(sell1.reload).to be_fulfilled
    end
  end

  it 'should fill based on the sell order price' do
    sell1 = user.sell_orders.create!(stock: stock, quantity: 100, price: 3)
    buy1 = user.buy_orders.create!(stock: stock, quantity: 200, price: 4)

    MatchOrders.new(stock: stock).call
    sell1.reload
    buy1.reload

    expect(sell1.fills.first.price).to eq sell1.price
  end

  context 'partial order matching' do
    it 'partially matches a buy order with an existing sell order' do
      sell1 = user.sell_orders.create!(stock: stock, quantity: 100, price: 3)
      buy1 = user.buy_orders.create!(stock: stock, quantity: 200, price: 4)

      MatchOrders.new(stock: stock).call
      sell1.reload
      buy1.reload

      expect(sell1).to be_fulfilled
      expect(buy1).to_not be_fulfilled

      fill = sell1.fills.first
      expect(buy1.fills).to include(fill)
      expect(fill.price).to eq 3
      expect(fill.quantity).to eq 100
      expect(fill.buy_order).to eq buy1
      expect(fill.sell_order).to eq sell1
    end

    it 'partially matches a sell order with an existing buy order' do
      buy1 = user.buy_orders.create!(stock: stock, quantity: 100, price: 4)
      sell1 = user.sell_orders.create!(stock: stock, quantity: 200, price: 3)

      MatchOrders.new(stock: stock).call
      sell1.reload
      buy1.reload

      expect(buy1).to be_fulfilled
      expect(sell1).to_not be_fulfilled

      fill = buy1.fills.first
      expect(sell1.fills).to include(fill)
      expect(fill.price).to eq 3
      expect(fill.quantity).to eq 100
      expect(fill.buy_order).to eq buy1
      expect(fill.sell_order).to eq sell1
    end

    context 'matching against already partially fulfilled orders' do
      it 'partially fulfilled order flow' do
        buy1 = user.buy_orders.create!(stock: stock, quantity: 100, price: 4)
        sell1 = user.sell_orders.create!(stock: stock, quantity: 200, price: 3)

        MatchOrders.new(stock: stock).call
        sell1.reload
        buy1.reload

        expect(buy1).to be_fulfilled
        expect(sell1).to_not be_fulfilled

        fill = buy1.fills.first

        # Next step
        buy2 = user.buy_orders.create!(stock: stock, quantity: 75, price: 4)

        MatchOrders.new(stock: stock).call
        sell1.reload
        buy2.reload

        expect(buy2).to be_fulfilled
        expect(sell1).to_not be_fulfilled

        fill2 = buy2.fills.first
        expect(sell1.fills).to include(fill, fill2)
        expect(fill2.price).to eq 3
        expect(fill2.quantity).to eq 75
        expect(fill2.buy_order).to eq buy2
        expect(fill.sell_order).to eq sell1

        # Expect larger order not to be fulfilled completely
        buy3 = user.buy_orders.create!(stock: stock, quantity: 150, price: 4)

        MatchOrders.new(stock: stock).call
        sell1.reload
        buy3.reload

        expect(buy3).to_not be_fulfilled
        expect(sell1).to be_fulfilled
      end
    end
  end

  # Mock that we're going to call transfer money
  it 'transfers money' do
    sell1 = user.sell_orders.create!(stock: stock, quantity: 100, price: 1)
    buy1 = user.buy_orders.create!(stock: stock, quantity: 100, price: 3)

    # use a mock here to check expect that we're gonna call TransferMoneyForFill

    MatchOrders.new(stock: stock).call
  end
end
