class MatchOrders
  def initialize(stock:)
    @stock = stock
  end

  def call
    Order.transaction do
      current_sell_orders = SellOrder.unfulfilled.book_ordered.stock(@stock).lock
      current_buy_orders = BuyOrder.unfulfilled.book_ordered.stock(@stock).lock

      match_orders(current_sell_orders, current_buy_orders)
    end
  end

  private

  def match_orders(sell_orders, buy_orders)
    buy_orders.each do |buy_order|
      sell_orders.each do |sell_order|
        if orders_match?(buy_order, sell_order)
          fulfill_order(buy_order, sell_order)

          # Skip to the next buy order
          break
        end
      end
    end
  end

  def orders_match?(buy_order, sell_order)
    !sell_order.fulfilled? &&
      match_price?(buy_order, sell_order)
  end

  def match_price?(buy_order, sell_order)
    buy_order.price >= sell_order.price
  end

  def fulfill_quantity!(buy_order, sell_order)
    buy_quantity_remaining = buy_order.quantity_remaining
    sell_quantity_remaining = sell_order.quantity_remaining

    if buy_quantity_remaining == sell_quantity_remaining
      buy_order.update(fulfilled_at: Time.now)
      sell_order.update(fulfilled_at: Time.now)

      sell_quantity_remaining
    elsif buy_quantity_remaining > sell_quantity_remaining
      # Sell order must become fulfilled
      sell_order.update(fulfilled_at: Time.now)

      sell_quantity_remaining
    elsif buy_quantity_remaining < sell_quantity_remaining
      # Buy order must become fulfilled
      buy_order.update(fulfilled_at: Time.now)

      buy_quantity_remaining
    end
  end

  def fulfill_order(buy_order, sell_order)
    fulfill_quantity = fulfill_quantity!(buy_order, sell_order)

    Fill.create!(buy_order: buy_order,
                 sell_order: sell_order,
                 price: sell_order.price,
                 quantity: fulfill_quantity)
  end
end
