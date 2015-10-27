require 'rails_helper'

RSpec.describe Order, kind: :model do
  it 'is valid' do
    order = build(:buy_order)

    expect(order).to be_valid
  end

  context 'there are buy and sell orders' do
  end

  describe 'invalid orders' do
    it 'requires a kind' do
      order = build(:buy_order)
      order.kind = nil

      expect(order).to be_invalid
    end

    it 'requires a stock' do
      order = build(:buy_order)
      order.stock = nil

      expect(order).to be_invalid
    end
  end

  describe '#fulfilled?' do
    # These are gross, I want to use one-liner syntax
    subject { build(:buy_order) }

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
end
