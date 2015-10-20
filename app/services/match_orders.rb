class MatchOrders
  def call
    @sell_queue = Order.sell
    @buy_queue = Order.buy

    # Basic matching of buy orders against sell orders
    @buy_queue.each do |buy_order|
      buy_order.update(furfilled: true)
      @sell_queue.each do |sell_order|
        if !sell_order.furfilled &&
            match_price?(buy_order, sell_order) &&
            match_quantity?(buy_order, sell_order)
          buy_order.update(furfilled: true)
          sell_order.update(furfilled: true)
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
