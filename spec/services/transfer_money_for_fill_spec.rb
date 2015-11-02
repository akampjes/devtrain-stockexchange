require 'rails_helper'

RSpec.describe TransferMoneyForFill, kind: :service do
  # How can I DRY this up in my factories
  # so that I don't need to keep over-riding values with uniq indexes
  let (:stock) { create(:stock) }
  let (:buy_order) { create(:buy_order, stock: stock, user: create(:user)) }
  let (:sell_order) { create(:sell_order, stock: stock, user: create(:user2)) }
  let (:fill) { create(:fill, buy_order: buy_order, sell_order: sell_order) }

  subject { TransferMoneyForFill.new(fill: fill) }

  it 'decreases the buyers money and increases the sellers money' do
    expect{ subject.call }.to change { fill.sell_order.user.money }.by(fill.quantity * fill.price)
    expect{ subject.call }.to change { fill.buy_order.user.money }.by(fill.quantity * fill.price * -1)
  end
end
