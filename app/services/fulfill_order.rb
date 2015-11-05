class FulfillOrder
  def initialize(buy_order:, sell_order:)
    @buy_order = buy_order
    @sell_order = sell_order
  end

  def call
    fill_quantity = [@buy_order.quantity_unfilled, @sell_order.quantity_unfilled].min

    fill = Fill.create!(
      buy_order: @buy_order,
      sell_order: @sell_order,
      price: @sell_order.price,
      quantity: fill_quantity
    )

    if @buy_order.quantity_unfilled.zero?
      @buy_order.update!(fulfilled_at: fill.created_at)
    end
    if @sell_order.quantity_unfilled.zero?
      @sell_order.update!(fulfilled_at: fill.created_at)
    end

    TransferMoneyForFill.new(fill: fill).call
  end
end
