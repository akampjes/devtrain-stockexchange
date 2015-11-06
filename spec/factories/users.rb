FactoryGirl.define do
  factory :user, class: User do
    email 'testuser1@example.com'
    password '12341234'
    password_confirmation '12341234'
    money 10_000
  end

  factory :user2, class: User do
    email 'testuser2@example.com'
    password '12341234'
    password_confirmation '12341234'
    money 10_000
  end
end
