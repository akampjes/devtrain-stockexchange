class MatchOrders
  def call
    @sell_queue = Order.sell.unfulfilled
    @buy_queue = Order.buy.unfulfilled

    # Basic matching of buy orders against sell orders
    @buy_queue.each do |buy_order|
      @sell_queue.each do |sell_order|
        if !sell_order.fulfilled &&
            match_price?(buy_order, sell_order) &&
            match_quantity?(buy_order, sell_order)
          buy_order.update(fulfilled: true)
          sell_order.update(fulfilled: true)
          # Skip to the next buy order
          break
        end
      end
    end
  end

  def match_price?(buy_order, sell_order)
    buy_order.price >= sell_order.price
  end

  def match_quantity?(buy_order, sell_order)
    # In this limited implementation we don't do partial order furfillment
    buy_order.quantity == sell_order.quantity
  end
end
