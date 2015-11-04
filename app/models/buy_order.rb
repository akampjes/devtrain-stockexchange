class BuyOrder < Order
  has_many :fills

  scope :book_ordered, -> { order(price: :asc, created_at: :asc) }

  validate :user_has_enough_money

  def user_has_enough_money
    if user.money_available - max_order_value < 0
      errors.add(:quantity, 'Not enough money available to buy this many shares')
    end
  end

  def max_order_value
    price * quantity
  end
end
