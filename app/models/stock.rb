class Stock < ActiveRecord::Base
  has_many :orders
  has_many :buy_orders
  has_many :sell_orders

  scope :for_user, -> (user) { includes(:orders).where(orders: {user: user}) }

  validates :name, :symbol, presence: true

  def market_price
    orders.fulfilled.first.try(:price)
  end
end
