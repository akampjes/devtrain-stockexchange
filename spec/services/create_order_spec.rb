require 'rails_helper'

RSpec.describe CreateOrder, kind: :service do
  let(:user) { create(:user) }
  let(:stock) { create(:stock) }

  let(:buy_order) { BuyOrder.new(user: user, stock: stock, quantity: 100, price: 4) }
  let(:sell_order) { SellOrder.new(user: user, stock: stock, quantity: 100, price: 4) }

  subject { CreateOrder.new(order: buy_order) }

  context 'valid orders' do
    it 'saves valid orders' do
      order = subject.call

      expect(order).to be_persisted
    end

    it 'queues a new matchorders job' do
      # how to test that this is called
    end
  end

  context 'invaild orders' do
    it 'adds errors if a user doesnt have enough money to buy shares' do
      user.update!(money: 0)

      order = subject.call

      expect(order.errors).to_not be_empty
    end

    it 'doesnt add errors to non buy orders' do
      user.update!(money: 0)

      # Fails for buy orders
      order = CreateOrder.new(order: buy_order).call
      expect(order.errors).to_not be_empty

      # Does't fail for sell orders
      order2 = CreateOrder.new(order: sell_order).call
      expect(order2.errors).to be_empty
    end

    it 'doesnt call matchorders job on an invaild order' do
      # how to test that this is called
    end
  end
end
