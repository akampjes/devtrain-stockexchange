FactoryGirl.define do
  factory :order do
    stock
    kind 'buy'
    price 1
    quantity 1
  end
end
