class Position
  attr_reader :stock, :total_quantity, :market_price, :cost

  def initialize(stock:, quantity:, market_price:, cost:)
    @stock = stock
    @total_quantity = quantity
    @market_price = market_price
    @cost = cost
  end

  def total_value
    total_quantity.to_i * market_price.to_i
  end

  def percentage_change
    (((total_value.to_f / cost.to_f) * 100) - 100).round(0)
  end
end
