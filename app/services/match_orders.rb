class MatchOrders
  def initialize(stock:)
    @stock = stock
  end

  def call
    Order.transaction do
      current_sell_orders = Order.sell.unfulfilled.stock(@stock).lock
      current_buy_orders = Order.buy.unfulfilled.stock(@stock).lock

      # Basic matching of buy orders against sell orders
      match_orders(current_sell_orders, current_buy_orders)
    end
  end

  def match_orders(sell_orders, buy_orders)
    buy_orders.each do |buy_order|
      sell_orders.each do |sell_order|
        if orders_match?(buy_order, sell_order)
          buy_order.update(fulfilled: true)
          sell_order.update(fulfilled: true)

          # Skip to the next buy order
          break
        end
      end
    end
  end

  private

  def orders_match?(buy_order, sell_order)
    !sell_order.fulfilled &&
      match_price?(buy_order, sell_order) &&
      match_quantity?(buy_order, sell_order)
  end

  def match_price?(buy_order, sell_order)
    buy_order.price >= sell_order.price
  end

  def match_quantity?(buy_order, sell_order)
    # In this limited implementation we don't do partial order furfillment
    buy_order.quantity == sell_order.quantity
  end
end
