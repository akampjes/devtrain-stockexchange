require 'rails_helper'

RSpec.describe GeneratePortfolio, kind: :service do
  let(:user) { create(:user) }
  let(:stock) { create(:stock) }
  subject { GeneratePortfolio.new(user: user) }

  context 'with orders' do
    it 'sums up some buy orders' do
      user.buy_orders.create!(stock: stock, quantity: 100, price: 4, fulfilled_at: Time.now)
      user.buy_orders.create!(stock: stock, quantity: 100, price: 3, fulfilled_at: Time.now)

      # market price is 3 (most recent traded)
      # 100 * 3 + 100 * 3 == 600
      expect(subject.call.first.total_value).to eq 600

      # cost was
      # 100 * 4 + 100 * 3 == 700
      expect(subject.call.first.cost).to eq 700
    end

    it 'sums up buy and subtracts sell orders' do
      user.buy_orders.create!(stock: stock, quantity: 100, price: 4, fulfilled_at: Time.now)
      user.sell_orders.create!(stock: stock, quantity: 50, price: 6, fulfilled_at: Time.now)
      user.buy_orders.create!(stock: stock, quantity: 100, price: 3, fulfilled_at: Time.now)

      # market price is 3 (most recent traded)
      # 100 * 3 + 100 * 3 - 50 * 3 == 600
      expect(subject.call.first.total_value).to eq 450

      # cost was
      # 100 * 4 + 100 * 3  - 50 * 6 == 700
      expect(subject.call.first.cost).to eq 400
    end
  end

  context 'with different users' do
    it 'only gives results for one users' do
      user2 = create(:user, email: 'blah@email.com')

      user.buy_orders.create!(stock: stock, quantity: 100, price: 4, fulfilled_at: Time.now)
      user.buy_orders.create!(stock: stock, quantity: 100, price: 3, fulfilled_at: Time.now)
      user2.buy_orders.create!(stock: stock, quantity: 150, price: 3, fulfilled_at: Time.now)

      expect(subject.call.first.total_value).to eq 600
    end
  end

  context 'with unfulfilled orders' do
    it 'doesnt count unfulfilled orders' do
      user.buy_orders.create!(stock: stock, quantity: 100, price: 4, fulfilled_at: Time.now)
      user.buy_orders.create!(stock: stock, quantity: 100, price: 3)

      expect(subject.call.first.total_value).to eq 400
    end
  end

  context 'with no orders' do
    it 'is empty' do
      expect(subject.call).to be_empty
    end
  end
end
