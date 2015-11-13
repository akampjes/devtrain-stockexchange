require 'rails_helper'

RSpec.describe FulfillOrder, kind: :service do
  let (:stock) { create(:stock) }
  let (:buy_order) { create(:buy_order, stock: stock, user: create(:user), quantity: 100, price: 3) }
  let (:sell_order) { create(:sell_order, stock: stock, user: create(:user2), quantity: 100, price: 2) }

  subject { FulfillOrder.new(buy_order: buy_order, sell_order: sell_order) }

  describe 'fulfilling orders' do
    context 'with equal sized orders' do
      it 'fulfills orders' do
        subject.call
        buy_order.reload
        sell_order.reload

        expect(buy_order).to be_fulfilled
        expect(sell_order).to be_fulfilled
      end
    end

    context 'with a smaller buy order than sell order' do
      it 'fulfills just the buy order' do
        buy_order.update!(quantity: 50)

        subject.call

        fill = buy_order.fills.first
        expect(fill.quantity).to eq 50
        expect(fill.price).to eq 2

        expect(buy_order).to be_fulfilled
        expect(sell_order).to_not be_fulfilled
      end
    end

    context 'with a smaller sell order than buy order' do
      it 'fulfills just the sell order' do
        sell_order.update!(quantity: 50)

        subject.call

        fill = sell_order.fills.first
        expect(fill.quantity).to eq 50
        expect(fill.price).to eq 2

        expect(buy_order).to_not be_fulfilled
        expect(sell_order).to be_fulfilled
      end
    end
  end

  context 'when transfering users money' do
    it 'transfers money from the buyer after fulfilling an order' do
      expect { subject.call }.to change {buy_order.user.money}
    end

    it 'transfers money to the seller after fulfilling an order' do
      expect { subject.call }.to change {sell_order.user.money}
    end

    it 'calls TransferMoneyForFill' do
      transfer_money_for_fill_instance = instance_double('TransferMoneyForFill')
      allow(TransferMoneyForFill).to receive(:new).and_return(transfer_money_for_fill_instance)
      expect(transfer_money_for_fill_instance).to receive(:call)

      subject.call
    end
  end
end
