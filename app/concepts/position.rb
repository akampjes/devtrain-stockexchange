class Position
  attr_reader :stock

  def initialize(stock:, quantity:, market_price:)
    @stock = stock
    @quantity = quantity
    @market_price = market_price
  end

  def total_quantity
    @quantity
  end

  def market_price
    @market_price
  end

  def total_value
    (total_quantity || 0) * (market_price || 0)
  end
end
