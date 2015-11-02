class TransferMoneyForFill
  def initialize(fill:)
    @fill = fill
  end

  def call
    buy_user = @fill.buy_order.user
    sell_user = @fill.sell_order.user

    amount = @fill.price * @fill.quantity

    buy_user.money = buy_user.money - amount
    sell_user.money = sell_user.money + amount

    buy_user.save
    sell_user.save
  end
end
