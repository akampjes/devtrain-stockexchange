require 'rails_helper'

require 'models/order_spec'

RSpec.describe SellOrder, type: :model do
  include_examples 'an order', 'sell_order'

  let(:sell_order) { create(:sell_order) }

  describe '.book_ordered' do
    it 'is ordered price descending' do
      sell_order2 = create(
        :sell_order,
        user: sell_order.user,
        stock: sell_order.stock,
        price: 2
      )

      expect(SellOrder.book_ordered.all).to eq [sell_order2, sell_order]
    end

    it 'is ordered by created ascending' do
      sell_order2 = create(
        :sell_order,
        user: sell_order.user,
        stock: sell_order.stock,
      )

      sell_order.update!(created_at: 1.day.ago)

      expect(SellOrder.book_ordered.all).to eq [sell_order, sell_order2]
    end
  end
end
