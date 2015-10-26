class Stock < ActiveRecord::Base
  has_many :orders

  validates :name, :symbol, presence: true

  def market_price
    orders.fulfilled.first.try(:price)
  end
end
