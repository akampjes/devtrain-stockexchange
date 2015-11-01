class GeneratePortfolio
  def initialize(user:)
    @user = user
  end

  def call
    Stock.for_user(@user).map do |stock|
      buy_orders = stock.buy_orders.fulfilled.for_user(@user)
      sell_orders = stock.sell_orders.fulfilled.for_user(@user)

      Position.new(stock: stock,
                   quantity: sum_orders(buy_orders, sell_orders),
                   market_price: stock.market_price,
                   cost: sum_cost(buy_orders, sell_orders)
                  )
    end
  end

  private

  def sum_orders(buy_orders, sell_orders)
    buy_orders.sum(:quantity) - sell_orders.sum(:quantity)
  end

  def sum_cost(buy_orders, sell_orders)
    cost(buy_orders) - cost(sell_orders)
  end

  def cost(orders)
    orders.reduce(0) do |sum, order|
      sum + order.price * order.quantity
    end
  end
end
