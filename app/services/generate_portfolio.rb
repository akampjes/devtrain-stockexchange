class GeneratePortfolio
  def initialize(user:)
    @user = user
  end

  def call
    Stock.for_user(@user).map do |stock|
      buy_orders = stock.buy_orders.fulfilled.for_user(@user)
      sell_orders = stock.sell_orders.fulfilled.for_user(@user)

      Position.new(
        stock: stock,
        quantity: sum_quantity(buy_orders, sell_orders),
        market_price: stock.market_price,
        cost: cost(buy_orders, sell_orders)
      )
    end
  end

  private

  def sum_quantity(buy_orders, sell_orders)
    buy_orders.sum(:quantity) - sell_orders.sum(:quantity)
  end

  def cost(buy_orders, sell_orders)
    sum_cost(buy_orders) - sum_cost(sell_orders)
  end

  def sum_cost(orders)
    orders.map { |order| order.price * order.quantity }.sum
  end
end
