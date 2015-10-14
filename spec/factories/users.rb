FactoryGirl.define do
  factory :user, class: User do
    email 'testuser1@example.com'
    password '12341234'
    password_confirmation '12341234'
  end
end
