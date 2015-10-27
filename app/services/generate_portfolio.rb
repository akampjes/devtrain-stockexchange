class GeneratePortfolio
  def initialize(user:)
    @user = user
  end

  def call
    Stock.for_user(@user).map do |stock|
      orders = stock.orders.fulfilled.for_user(@user)

      Position.new(stock: stock,
                   quantity: orders.sum(:quantity),
                   market_price: stock.market_price)
    end
  end
end
