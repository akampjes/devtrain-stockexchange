require 'rails_helper'

RSpec.describe MatchOrders, kind: :service do
  let(:stock) { create(:stock) }
  let(:user) { create(:user) }

  describe 'basic matching of orders' do
    it 'matches a buy order against exsiting sell orders' do
      sell1 = user.sell_orders.create!(stock: stock, quantity: 100, price: 4)
      sell2 = user.sell_orders.create!(stock: stock, quantity: 100, price: 1)
      buy1 = user.buy_orders.create!(stock: stock, quantity: 100, price: 3)

      MatchOrders.new(stock: stock).call

      expect(sell1.reload).to_not be_fulfilled
      expect(sell2.reload).to be_fulfilled
      expect(buy1.reload).to be_fulfilled
    end

    it 'matches a sell order against existing buy orders' do
      buy1 = user.buy_orders.create!(stock: stock, quantity: 100, price: 3)
      buy2 = user.buy_orders.create!(stock: stock, quantity: 100, price: 2)
      sell1 =  user.sell_orders.create!(stock: stock, quantity: 100, price: 3)

      MatchOrders.new(stock: stock).call

      expect(buy1.reload).to be_fulfilled
      expect(buy2.reload).to_not be_fulfilled
      expect(sell1.reload).to be_fulfilled
    end
  end

  describe 'order sorting/ordering' do
    it 'matches a buy order against the oldest matching sell order' do
      sell1 = user.sell_orders.create!(stock: stock, quantity: 100, price: 3)
      sell2 = user.sell_orders.create!(stock: stock, quantity: 100, price: 3, created_at: 1.day.ago)
      buy1 = user.buy_orders.create!(stock: stock, quantity: 100, price: 3)

      MatchOrders.new(stock: stock).call

      expect(sell1.reload).to_not be_fulfilled
      expect(sell2.reload).to be_fulfilled
      expect(buy1.reload).to be_fulfilled
    end

    it 'matches a sell order against the most oldest matching buy order' do
      buy1 = user.buy_orders.create!(stock: stock, quantity: 100, price: 3)
      buy2 = user.buy_orders.create!(stock: stock, quantity: 100, price: 3, created_at: 1.day.ago)
      sell1 = user.sell_orders.create!(stock: stock, quantity: 100, price: 3)

      MatchOrders.new(stock: stock).call

      expect(buy1.reload).to_not be_fulfilled
      expect(buy2.reload).to be_fulfilled
      expect(sell1.reload).to be_fulfilled
    end
  end

  context 'empty orders' do
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

  context "fulfilled orders" do
    it 'doesnt match against a fulfilled sell order' do
      sell1 = user.sell_orders.create!(stock: stock, quantity: 100, price: 3, fulfilled_at: Time.now)
      buy1 = user.buy_orders.create!(stock: stock, quantity: 100, price: 3)

      MatchOrders.new(stock: stock).call

      expect(sell1.reload).to be_fulfilled
      expect(buy1.reload).to_not be_fulfilled
    end

    it 'doesnt match against a fulfilled buy order' do
      buy1 = user.buy_orders.create!(stock: stock, quantity: 100, price: 2, fulfilled_at: Time.now)
      sell1 =  user.sell_orders.create!(stock: stock, quantity: 100, price: 2)

      MatchOrders.new(stock: stock).call

      expect(buy1.reload).to be_fulfilled
      expect(sell1.reload).to_not be_fulfilled
    end
  end

  describe 'matching multiple orders' do
    it 'matches multiple buy orders' do
      sell1 = user.sell_orders.create!(stock: stock, quantity: 200, price: 2)
      buy1 = user.buy_orders.create!(stock: stock, quantity: 100, price: 3)
      buy2 = user.buy_orders.create!(stock: stock, quantity: 100, price: 3)

      MatchOrders.new(stock: stock).call

      expect(sell1.reload).to be_fulfilled
      expect(buy1.reload).to be_fulfilled
      expect(buy2.reload).to be_fulfilled
    end

    it 'matches multiple sell orders' do
      sell1 = user.sell_orders.create!(stock: stock, quantity: 100, price: 2)
      sell2 = user.sell_orders.create!(stock: stock, quantity: 100, price: 2)
      buy1 = user.buy_orders.create!(stock: stock, quantity: 200, price: 4)

      MatchOrders.new(stock: stock).call

      expect(sell1.reload).to be_fulfilled
      expect(sell2.reload).to be_fulfilled
      expect(buy1.reload).to be_fulfilled
    end
  end

  # Thinking...
  # Don't need test that money is transfered, just that the side some orders are
  # fulfilled (the obvious outcome from FulfillOrder), see above.
  # Then in FulfillOrder we can do the money transfer :)

  # Woot! Found a good use for mocks
  describe 'FulfillOrder' do
    it 'calls FulfillOrder on orders' do
      buy1 = user.buy_orders.create!(stock: stock, quantity: 100, price: 4)
      sell1 = user.sell_orders.create!(stock: stock, quantity: 100, price: 3)

      fulfill_order_instance = instance_double('FulfillOrder')
      allow(FulfillOrder).to receive(:new).with(buy_order: buy1, sell_order: sell1).and_return(fulfill_order_instance)
      expect(fulfill_order_instance).to receive(:call)

      MatchOrders.new(stock: stock).call
    end

    it 'doesnt call FulfillOrder on orders that dont match' do
      buy1 = user.buy_orders.create!(stock: stock, quantity: 100, price: 2)
      sell1 = user.sell_orders.create!(stock: stock, quantity: 100, price: 3)

      fulfill_order_instance = instance_double('FulfillOrder')
      allow(FulfillOrder).to receive(:new).with(buy_order: buy1, sell_order: sell1).and_return(fulfill_order_instance)
      expect(fulfill_order_instance).to_not receive(:call)

      MatchOrders.new(stock: stock).call
    end
  end

  # Thinking...
  # Don't need test that money is transfered, just that the side some orders are
  # fulfilled (the obvious outcome from FulfillOrder), see above.
  # Then in FulfillOrder we can do the money transfer :)
  #
  # this matches everything because the actual order fulfilling is never happening
  # this means that it fails the second time that fulfillorder is called because
  # it decided to match the sell1 even after it had already matched sell2 and therefore
  # had already fulfilled it.
  #
  #it 'matches by date first' do
  #  sell1 = user.sell_orders.create!(stock: stock, quantity: 133, price: 3)
  #  sell2 = user.sell_orders.create!(stock: stock, quantity: 133, price: 3, created_at: 1.day.ago)
  #  buy1 = user.buy_orders.create!(stock: stock, quantity: 133, price: 3)

  #  fulfill_order_instance = instance_double('FulfillOrder')
  #  fulfill_order_instance2 = instance_double('FulfillOrder')
  #  allow(FulfillOrder).to receive(:new).with(buy_order: buy1, sell_order: sell2).and_return(fulfill_order_instance)
  #  expect(fulfill_order_instance).to receive(:call)

  #  MatchOrders.new(stock: stock).call
  #end
end
