class SellOrder < Order
  has_many :fills

  scope :book_ordered, -> { order(price: :desc, created_at: :asc) }
end
