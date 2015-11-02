require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#money_available' do
    let(:buy_order) { create(:buy_order) }

    it 'has money available' do
      user = buy_order.user

      expect(user.money_available).to eq (user.money - buy_order.max_order_value)
    end
  end
end
