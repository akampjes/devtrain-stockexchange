class BuyOrder < Order
  has_many :fills

  scope :book_ordered, -> { order(price: :asc, created_at: :asc) }

  def max_order_value
    price * quantity
  end
end
