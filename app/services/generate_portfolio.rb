class GeneratePortfolio
  def initialize(user:)
    @user = user
  end

  def call
    # get groups of order for each stock that user has
    #@orders = Order.where(user: @user)

    Order.where(user: @user).select(:stock_id).distinct
    #stocks = Order.select(:stock).distinct

    portfolio = []
    Stock.includes(:orders).where(orders: {user: @user}).each do |stock|
      orders = stock.orders.fulfilled.where(user: @user)

      market_price = stock.market_price
      total_quantity = orders.sum(:quantity)

      portfolio << Position.new(stock: stock,
                                quantity: total_quantity,
                                market_price: market_price)
    end

    portfolio
  end
end
