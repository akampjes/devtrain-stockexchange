FactoryGirl.define do
  factory :buy_order, class: BuyOrder do
    stock
    user
    price 1
    quantity 1
  end

  factory :sell_order, class: SellOrder do
    stock
    user
    price 1
    quantity 1
  end
end
