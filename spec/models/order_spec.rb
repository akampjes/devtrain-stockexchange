require 'rails_helper'

# this is where i include factorygirl
RSpec.describe Order, kind: :model do
  it 'is valid' do
    order = build(:order)
    expect(order).to be_valid
  end

  context 'there are buy and sell orders' do
  end

  describe 'invalid orders' do
    it 'requires a kind' do
      order = build(:order)
      order.kind = nil
      expect(order).to be_invalid
    end

    it 'requires a stock' do
      order = build(:order)
      order.stock = nil
      expect(order).to be_invalid
    end
  end
end
