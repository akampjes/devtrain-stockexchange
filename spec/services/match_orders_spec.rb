require 'rails_helper'

RSpec.describe MatchOrders, kind: :service do
  let(:stock) { create(:stock) }
  let(:user) { create(:user) }

  describe 'matching' do
    describe 'price ordering' do
      it 'matches a buy order against lower priced sell order' do
        sell1 = user.sell_orders.create!(stock: stock, quantity: 100, price: 4)
        sell2 = user.sell_orders.create!(stock: stock, quantity: 100, price: 1)
        buy1 = user.buy_orders.create!(stock: stock, quantity: 100, price: 3)

        MatchOrders.new(stock: stock).call

        expect(sell1.reload).to_not be_fulfilled
        expect(sell2.reload).to be_fulfilled
        expect(buy1.reload).to be_fulfilled
      end

      it 'matches a sell order against higher priced order' do
        buy1 = user.buy_orders.create!(stock: stock, quantity: 100, price: 3)
        buy2 = user.buy_orders.create!(stock: stock, quantity: 100, price: 2)
        sell1 =  user.sell_orders.create!(stock: stock, quantity: 100, price: 3)

        MatchOrders.new(stock: stock).call

        expect(buy1.reload).to be_fulfilled
        expect(buy2.reload).to_not be_fulfilled
        expect(sell1.reload).to be_fulfilled
      end
    end

    describe 'time ordering' do
      it 'fulfills a buy order against the oldest matching sell order' do
        sell1 = user.sell_orders.create!(stock: stock, quantity: 100, price: 3)
        sell2 = user.sell_orders.create!(stock: stock, quantity: 100, price: 3, created_at: 1.day.ago)
        buy1 = user.buy_orders.create!(stock: stock, quantity: 100, price: 3)

        MatchOrders.new(stock: stock).call

        expect(sell1.reload).to_not be_fulfilled
        expect(sell2.reload).to be_fulfilled
        expect(buy1.reload).to be_fulfilled
      end

      it 'fulfills a sell order against the most oldest matching buy order' do
        buy1 = user.buy_orders.create!(stock: stock, quantity: 100, price: 3)
        buy2 = user.buy_orders.create!(stock: stock, quantity: 100, price: 3, created_at: 1.day.ago)
        sell1 = user.sell_orders.create!(stock: stock, quantity: 100, price: 3)

        MatchOrders.new(stock: stock).call

        expect(buy1.reload).to_not be_fulfilled
        expect(buy2.reload).to be_fulfilled
        expect(sell1.reload).to be_fulfilled
      end
    end
  end

  context "when no matches found" do
    context 'when no sell orders' do
      it 'fulfills nothing' do
        buy1 = user.buy_orders.create!(stock: stock, quantity: 100, price: 3)
        buy2 = user.buy_orders.create!(stock: stock, quantity: 100, price: 3)

        MatchOrders.new(stock: stock).call

        expect(buy1.reload).to_not be_fulfilled
        expect(buy2.reload).to_not be_fulfilled
      end
    end

    context 'when no buy orders' do
      it 'fulfills nothing' do
        sell1 = user.sell_orders.create!(stock: stock, quantity: 100, price: 3)
        sell2 = user.sell_orders.create!(stock: stock, quantity: 100, price: 3)

        MatchOrders.new(stock: stock).call

        expect(sell1.reload).to_not be_fulfilled
        expect(sell2.reload).to_not be_fulfilled
      end
    end

    context 'when sell order already fulfilled' do
      it 'doesnt fulfill any more orders' do
        sell1 = user.sell_orders.create!(stock: stock, quantity: 100, price: 3, fulfilled_at: Time.now)
        buy1 = user.buy_orders.create!(stock: stock, quantity: 100, price: 3)

        MatchOrders.new(stock: stock).call

        expect(sell1.reload).to be_fulfilled
        expect(buy1.reload).to_not be_fulfilled
      end
    end

    context 'when buy order already fulfilled' do
      it 'doesnt fulfill any more orders' do
        buy1 = user.buy_orders.create!(stock: stock, quantity: 100, price: 2, fulfilled_at: Time.now)
        sell1 =  user.sell_orders.create!(stock: stock, quantity: 100, price: 2)

        MatchOrders.new(stock: stock).call

        expect(buy1.reload).to be_fulfilled
        expect(sell1.reload).to_not be_fulfilled
      end
    end

    context 'when an order is canceled' do
      it 'doesnt fulfill an order' do
        buy1 = user.buy_orders.create!(stock: stock, quantity: 100, price: 2, status: 'canceled')
        sell1 =  user.sell_orders.create!(stock: stock, quantity: 100, price: 2)

        MatchOrders.new(stock: stock).call

        expect(buy1.reload).to_not be_fulfilled
        expect(sell1.reload).to_not be_fulfilled
      end
    end


    it 'doesnt call FulfillOrder' do
      buy1 = user.buy_orders.create!(stock: stock, quantity: 100, price: 2)
      sell1 = user.sell_orders.create!(stock: stock, quantity: 100, price: 3)

      fulfill_order_instance = instance_double('FulfillOrder')
      allow(FulfillOrder).to receive(:new).with(buy_order: buy1, sell_order: sell1).and_return(fulfill_order_instance)
      expect(fulfill_order_instance).to_not receive(:call)

      MatchOrders.new(stock: stock).call
    end
  end

  context 'when matching multiple buy orders' do
    it 'fulfills orders' do
      sell1 = user.sell_orders.create!(stock: stock, quantity: 200, price: 2)
      buy1 = user.buy_orders.create!(stock: stock, quantity: 100, price: 3)
      buy2 = user.buy_orders.create!(stock: stock, quantity: 100, price: 3)

      MatchOrders.new(stock: stock).call

      expect(sell1.reload).to be_fulfilled
      expect(buy1.reload).to be_fulfilled
      expect(buy2.reload).to be_fulfilled
    end
  end

  context 'when matching multiple sell orders' do
    it 'fulfills orders' do
      sell1 = user.sell_orders.create!(stock: stock, quantity: 100, price: 2)
      sell2 = user.sell_orders.create!(stock: stock, quantity: 100, price: 2)
      buy1 = user.buy_orders.create!(stock: stock, quantity: 200, price: 4)

      MatchOrders.new(stock: stock).call

      expect(sell1.reload).to be_fulfilled
      expect(sell2.reload).to be_fulfilled
      expect(buy1.reload).to be_fulfilled
    end
  end

  # Woot! Found a good use for mocks
  context 'when orders match FulfillOrder might be called' do
    it 'calls FulfillOrder on orders' do
      buy1 = user.buy_orders.create!(stock: stock, quantity: 100, price: 4)
      sell1 = user.sell_orders.create!(stock: stock, quantity: 100, price: 3)

      fulfill_order_instance = instance_double('FulfillOrder')
      allow(FulfillOrder).to receive(:new).with(buy_order: buy1, sell_order: sell1).and_return(fulfill_order_instance)
      expect(fulfill_order_instance).to receive(:call)

      MatchOrders.new(stock: stock).call
    end
  end
end
