class TransferMoneyForFill
  def initialize(fill:)
    @fill = fill
  end

  def call
    Order.transaction do
      buy_user = @fill.buy_order.user
      sell_user = @fill.sell_order.user

      amount = @fill.price * @fill.quantity

      buy_user.update!(money: buy_user.money - amount)
      sell_user.update!(money: sell_user.money + amount)
    end
  end
end
