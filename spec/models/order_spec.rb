require 'rails_helper'

RSpec.shared_examples 'an order' do |order_type|
  context 'when order is valid' do
    subject { build(order_type) }
    it { is_expected.to be_valid }
  end

  context 'when order is invalid' do
    it 'is invalid without a stock' do
      order = build(order_type)
      order.stock = nil

      expect(order).to be_invalid
    end
  end

  describe '#fulfilled?' do
    subject { build(order_type) }

    it { is_expected.to_not be_fulfilled }

    context 'when fulfilled_at is set' do
      before { subject.fulfilled_at = Time.now }

      it { is_expected.to be_fulfilled }
    end
  end

  describe '#canceled?' do
    subject { build(order_type) }

    it { is_expected.to_not be_canceled }

    context 'when status is set to canceled' do
      before { subject.status = 'canceled' }

      it { is_expected.to be_canceled }
    end
  end

  describe '#active?' do
    subject { build(order_type) }

    it { is_expected.to be_active }

    context 'when status is set to canceled' do
      it 'is not active' do
        subject.status = 'canceled'

        expect(subject).to_not be_active
      end
    end

    context 'when fulfilled_at is set' do
      it 'is not active' do
        subject.fulfilled_at = Time.now

        expect(subject).to_not be_active
      end
    end
  end

  describe '#cancel' do
    subject { build(order_type) }

    it 'cancels an order' do
      subject.cancel

      expect(subject).to be_canceled
    end

    context 'when order is already fulfilled' do
      it 'cant be canceled' do
        subject.fulfilled_at = Time.now
        subject.cancel

        expect(subject).to_not be_canceled
      end
    end
  end

  context 'with filled orders' do
    let(:user) { create(:user) }
    let(:stock) { create(:stock) }
    let(:buy_order) { create(:buy_order, stock: stock, user: user) }
    let(:sell_order) { create(:sell_order, stock: stock, user: user) }

    before do
      Fill.create!(
        buy_order: buy_order,
        sell_order: sell_order,
        price: 1,
        quantity: 75
      )
    end

    describe '#quantity_filled' do
      it 'reports the quantity of fills on an order' do
        expect(buy_order.quantity_filled).to eq 75
        expect(sell_order.quantity_filled).to eq 75
      end
    end

    describe '#quantity_unfilled' do
      it 'reports the quantity remaining after filling some part of an order' do
        expect(buy_order.quantity_unfilled).to eq 25
        expect(sell_order.quantity_unfilled).to eq 25
      end
    end
  end
end
