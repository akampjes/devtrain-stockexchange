FactoryGirl.define do
  factory :buy_order, class: Order do
    stock
    user
    kind 'buy'
    price 1
    quantity 1
  end

  factory :sell_order, class: Order do
    stock
    user
    kind 'sell'
    price 1
    quantity 1
  end
end
