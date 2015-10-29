class MatchOrders
  def initialize(stock:)
    @stock = stock
  end

  def call
    Order.transaction do
      current_sell_orders = SellOrder.unfulfilled.book_ordered.stock(@stock).lock
      current_buy_orders = BuyOrder.unfulfilled.book_ordered.stock(@stock).lock

      # Basic matching of buy orders against sell orders
      match_orders(current_sell_orders, current_buy_orders)
    end
  end

  def match_orders(sell_orders, buy_orders)
    buy_orders.each do |buy_order|
      sell_orders.each do |sell_order|
        if orders_match?(buy_order, sell_order)
          #buy_order.update(fulfilled_at: Time.now)
          #sell_order.update(fulfilled_at: Time.new)

          # When doing partial order matching, at least one of the orders will
          # end up being fulfilled.
          #
          #
          # Which `value` are we going to take?
          #
          if buy_order.quantity == sell_order.quantity
            buy_order.update(fulfilled_at: Time.now)
            sell_order.update(fulfilled_at: Time.now)
            Fill.create!(buy_order: buy_order,
                         sell_order: sell_order,
                         price: sell_order.price,
                         quantity: sell_order.quantity)
          elsif buy_order.quantity < sell_order.quantity
            # buy order becomes fulfilled
            buy_order.update(fulfilled_at: Time.now)
            Fill.create!(buy_order: buy_order,
                         sell_order: sell_order,
                         price: sell_order.price,
                         quantity: buy_order.quantity)
          elsif buy_order.quantity > sell_order.quantity
            # sell order becomes fulfilled
            sell_order.update(fulfilled_at: Time.now)
            Fill.create!(buy_order: buy_order,
                         sell_order: sell_order,
                         price: sell_order.price,
                         quantity: sell_order.quantity)
          else
            # should never be here
            puts "SHOULDNT BE HERE"
          end

          # Skip to the next buy order
          break
        end
      end
    end
  end

  private

  # Need to be able to query if an order is entirely fulfilled

  def orders_match?(buy_order, sell_order)
    sell_order.fulfilled_at.nil? &&
      match_price?(buy_order, sell_order)
  end

  def match_price?(buy_order, sell_order)
    buy_order.price >= sell_order.price
  end

  def match_quantity?(buy_order, sell_order)
    # In this limited implementation we don't do partial order furfillment
    # needs to check if there's enough quantity to fulfill one of the orders
    # there should be?
    #
    # then we can delete this and just be adding a new fill
    buy_order.quantity == sell_order.quantity
  end
end
