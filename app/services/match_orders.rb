class MatchOrders
  def initialize(stock:)
    @stock = stock
  end

  def call
    Order.transaction do
      current_sell_orders = SellOrder.active.unfulfilled.book_ordered.stock(@stock).lock
      current_buy_orders = BuyOrder.active.unfulfilled.book_ordered.stock(@stock).lock

      match_orders(current_sell_orders, current_buy_orders)
    end
  end

  private

  def match_orders(sell_orders, buy_orders)
    buy_orders.each do |buy_order|
      sell_orders.each do |sell_order|
        fulfill_order!(buy_order, sell_order) if orders_match?(buy_order, sell_order)
      end
    end
  end

  def orders_match?(buy_order, sell_order)
    !sell_order.fulfilled? &&
      !buy_order.fulfilled? &&
      match_price?(buy_order, sell_order)
  end

  def match_price?(buy_order, sell_order)
    buy_order.price >= sell_order.price
  end

  def fulfill_order!(buy_order, sell_order)
    FulfillOrder.new(buy_order: buy_order, sell_order: sell_order).call
  end
end
