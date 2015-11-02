require 'rails_helper'

require 'models/order_spec'

RSpec.describe BuyOrder, type: :model do
  include_examples 'an order', 'buy_order'

  describe '#max_order_value' do
    subject { create(:buy_order) }

    it 'calculates the max possible order value' do
      expect(subject.max_order_value).to eq (subject.price * subject.quantity)
    end
  end
end
