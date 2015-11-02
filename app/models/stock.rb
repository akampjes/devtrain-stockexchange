class Stock < ActiveRecord::Base
  has_many :orders

  scope :for_user, -> (user) { includes(:orders).where(orders: {user: user}) }

  validates :name, :symbol, presence: true

  def market_price
    orders.fulfilled.first.try(:price)
  end
end
