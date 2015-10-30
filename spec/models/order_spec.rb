require 'rails_helper'

RSpec.shared_examples 'an order' do |order_type|
  it 'is valid' do
    order = build(order_type)

    expect(order).to be_valid
  end

  context 'there are buy and sell orders' do
  end

  describe 'invalid orders' do
    it 'requires a stock' do
      order = build(order_type)
      order.stock = nil

      expect(order).to be_invalid
    end
  end

  describe '#fulfilled?' do
    # These are gross, I want to use one-liner syntax
    subject { build(order_type) }

    context 'when fulfilled_at is set' do
      it 'it is fulfilled' do
        subject.fulfilled_at = Time.now

        expect(subject).to be_fulfilled
      end
    end

    context 'when fulfilled_at is not set' do
      it 'is not fulfilled' do
        expect(subject).to_not be_fulfilled
      end
    end
  end

  describe '#fill' do
    # test some shit here
    # make sure that the selectors are working right
    #
    it 'is a buy kind of order' do
    end

    it 'is a sell kind of order' do
    end
  end

  context 'order quantities being calculated from filled orders' do
    let(:user) { create(:user) }
    let(:stock) { create(:stock) }
    let(:buy_order) { create(:buy_order, stock: stock, user: user) }
    let(:sell_order) { create(:sell_order, stock: stock, user: user) }

    before do
      Fill.create!(buy_order: buy_order,
                   sell_order: sell_order,
                   price: 1,
                   quantity: 75)
    end

    describe '#quantity_filled' do
      it 'reports the quantity of fills on an order' do
        expect(buy_order.quantity_filled).to eq 75
        expect(sell_order.quantity_filled).to eq 75
      end
    end

    describe '#quantity_remaining' do
      it 'reports the quantity remaining after filling some part of an order' do
        expect(buy_order.quantity_remaining).to eq 25
        expect(sell_order.quantity_remaining).to eq 25

      end
    end
  end
end
