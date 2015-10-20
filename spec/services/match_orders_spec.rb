require 'rails_helper'

RSpec.describe MatchOrders, kind: :service do
  let(:stock) { create(:stock) }
  let(:user) { create(:user) }

  context 'a buy order matches against existing sell orders' do
    it 'gets furfilled' do
      sell1 =  user.orders.sell.create!(stock: stock, quantity: 100, price: 4)
      sell2 = user.orders.sell.create!(stock: stock, user: user, kind: 'sell', quantity: 100, price: 1)
      buy1 = user.orders.buy.create!(stock: stock, user: user, kind: 'buy', quantity: 100, price: 3)

      MatchOrders.new.call

      expect(buy1.reload.furfilled).to be true
      expect(sell2.reload.furfilled).to be true
      expect(sell1.reload.furfilled).to be nil
    end
  end
end
