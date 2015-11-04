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
        fulfill_order(buy_order, sell_order) if orders_match?(buy_order, sell_order)
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

  def fulfill_order(buy_order, sell_order)
    fill_quantity = [buy_order.quantity_unfilled, sell_order.quantity_unfilled].min

    fill = Fill.create!(
      buy_order: buy_order,
      sell_order: sell_order,
      price: sell_order.price,
      quantity: fill_quantity
    )

    if buy_order.quantity_unfilled.zero?
      buy_order.update!(fulfilled_at: fill.created_at)
    end
    if sell_order.quantity_unfilled.zero?
      sell_order.update!(fulfilled_at: fill.created_at)
    end

    TransferMoneyForFill.new(fill: fill).call
  end
end
