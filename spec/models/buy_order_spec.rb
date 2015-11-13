require 'rails_helper'

require 'models/order_spec'

RSpec.describe BuyOrder, type: :model do
  include_examples 'an order', 'buy_order'

  let(:buy_order) { create(:buy_order) }

  describe '#max_order_value' do
    it 'calculates the max possible order value' do
      expect(buy_order.max_order_value).to eq (buy_order.price * buy_order.quantity)
    end
  end

  describe '.book_ordered' do
    it 'is ordered price ascending' do
      buy_order.price += 1
      buy_order.save!

      buy_order2 = create(
        :buy_order,
        user: buy_order.user,
        stock: buy_order.stock,
        price: 1
      )

      expect(BuyOrder.book_ordered.all).to eq [buy_order2, buy_order]
    end

    it 'is ordered by created ascending' do
      buy_order2 = create(
        :buy_order,
        user: buy_order.user,
        stock: buy_order.stock,
      )

      buy_order.update!(created_at: 1.day.ago)

      expect(BuyOrder.book_ordered.all).to eq [buy_order, buy_order2]
    end
  end
end
