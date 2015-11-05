class CreateOrder
  def initialize(order:)
    @order = order
  end

  def call
    unless user_has_enough_money_for_buy_order?
      @order.errors.add(:quantity, 'Not enough money available to buy this many shares')
    else
      @order.save
    end

    MatchOrdersJob.perform_later(stock: @order.stock) if @order.errors.empty?

    @order
  end

  def user_has_enough_money_for_buy_order?
    return true if @order.type != 'BuyOrder'

    @order.user.money_available >= @order.max_order_value
  end
end
