require 'rails_helper'

RSpec.describe CreateOrder, kind: :service do
  let(:user) { create(:user) }
  let(:stock) { create(:stock) }

  let(:buy_order) { BuyOrder.new(user: user, stock: stock, quantity: 100, price: 4) }
  let(:sell_order) { SellOrder.new(user: user, stock: stock, quantity: 100, price: 4) }

  subject { CreateOrder.new(order: buy_order) }

  context 'with a valid order' do
    it 'is saves the order' do
      order = subject.call

      expect(order).to be_persisted
    end

    it 'queues a new matchorders job' do
      subject.call

      expect(MatchOrdersJob).to have_been_enqueued.once.with(deserialize_as(stock: stock))
    end
  end

  context 'with an invaild order' do
    it 'is invaild without enough money' do
      user.update!(money: 0)

      order = subject.call

      expect(order.errors).to_not be_empty
    end

    it 'isnt invaild on sell orders' do
      user.update!(money: 0)

      # Fails for buy orders
      order = CreateOrder.new(order: buy_order).call
      expect(order.errors).to_not be_empty

      # Does't fail for sell orders
      order2 = CreateOrder.new(order: sell_order).call
      expect(order2.errors).to be_empty
    end

    it 'doesnt call matchorders job on an invaild order' do
      user.update!(money: 0)
      subject.call

      expect(MatchOrdersJob).to_not have_been_enqueued
    end
  end
end
