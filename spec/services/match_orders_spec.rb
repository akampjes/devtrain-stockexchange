require 'rails_helper'

RSpec.describe MatchOrders, kind: :service do
  let(:stock) { create(:stock) }
  let(:user) { create(:user) }

  context 'a buy order matches against existing sell orders' do
    it 'gets fulfilled' do
      sell1 = user.orders.sell.create!(stock: stock, quantity: 100, price: 4)
      sell2 = user.orders.sell.create!(stock: stock, quantity: 100, price: 1)
      buy1 = user.orders.buy.create!(stock: stock, quantity: 100, price: 3)

      MatchOrders.new.call

      expect(sell1.reload.fulfilled).to be nil
      expect(sell2.reload.fulfilled).to be true
      expect(buy1.reload.fulfilled).to be true
    end
  end

  context 'a sell order matches against exsting buy orders' do
    it 'gets fulfilled' do
      buy1 = user.orders.buy.create!(stock: stock, quantity: 100, price: 3)
      buy2 = user.orders.buy.create!(stock: stock, quantity: 100, price: 2)
      sell1 =  user.orders.sell.create!(stock: stock, quantity: 100, price: 3)

      MatchOrders.new.call

      expect(buy1.reload.fulfilled).to be true
      expect(buy2.reload.fulfilled).to be nil
      expect(sell1.reload.fulfilled).to be true
    end
  end

  context 'a buy order matches against the most oldest matching sell order' do
    it 'gets fulfilled' do
      sell1 = user.orders.sell.create!(stock: stock, quantity: 100, price: 3)
      sell2 = user.orders.sell.create!(stock: stock, quantity: 100, price: 3, created_at: Time.now - 1.day)
      buy1 = user.orders.buy.create!(stock: stock, quantity: 100, price: 3)

      MatchOrders.new.call

      expect(sell1.reload.fulfilled).to be nil
      expect(sell2.reload.fulfilled).to be true
      expect(buy1.reload.fulfilled).to be true
    end
  end

  context 'a sell order matches against the most oldest matching buy order' do
    it 'gets fulfilled' do
      buy1 = user.orders.buy.create!(stock: stock, quantity: 100, price: 3)
      buy2 = user.orders.buy.create!(stock: stock, quantity: 100, price: 3, created_at: Time.now - 1.day)
      sell1 = user.orders.sell.create!(stock: stock, quantity: 100, price: 3)

      MatchOrders.new.call

      expect(buy1.reload.fulfilled).to be nil
      expect(buy2.reload.fulfilled).to be true
      expect(sell1.reload.fulfilled).to be true
    end
  end

  context 'there are no sell orders' do
    it 'does nothing' do
      buy1 = user.orders.buy.create!(stock: stock, quantity: 100, price: 3)
      buy2 = user.orders.buy.create!(stock: stock, quantity: 100, price: 3)

      MatchOrders.new.call

      expect(buy1.reload.fulfilled).to be nil
      expect(buy2.reload.fulfilled).to be nil
    end
  end

  context 'there are no buy orders' do
    it 'does nothing' do
      sell1 = user.orders.sell.create!(stock: stock, quantity: 100, price: 3)
      sell2 = user.orders.sell.create!(stock: stock, quantity: 100, price: 3)

      MatchOrders.new.call

      expect(sell1.reload.fulfilled).to be nil
      expect(sell2.reload.fulfilled).to be nil
    end
  end

  context "fulfilled orders, aren't counted twice" do
    it 'picks an unfulfilled sell order' do
      sell1 = user.orders.sell.create!(stock: stock, quantity: 100, price: 3, fulfilled: true)
      sell2 = user.orders.sell.create!(stock: stock, quantity: 100, price: 3)
      buy1 = user.orders.buy.create!(stock: stock, quantity: 100, price: 3)

      MatchOrders.new.call

      expect(sell1.reload.fulfilled).to be true
      expect(sell2.reload.fulfilled).to be true
      expect(buy1.reload.fulfilled).to be true

    end

    it 'picks an unfulfilled buy order' do
      buy1 = user.orders.buy.create!(stock: stock, quantity: 100, price: 2, fulfilled: true)
      buy2 = user.orders.buy.create!(stock: stock, quantity: 100, price: 2)
      sell1 =  user.orders.sell.create!(stock: stock, quantity: 100, price: 2)

      MatchOrders.new.call

      expect(buy1.reload.fulfilled).to be true
      expect(buy2.reload.fulfilled).to be true
      expect(sell1.reload.fulfilled).to be true
    end
  end


end
