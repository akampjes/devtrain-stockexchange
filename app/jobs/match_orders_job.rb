class MatchOrdersJob < ActiveJob::Base
  queue_as :default

  def perform(stock:)
    MatchOrders.new(stock: stock).call
  end
end
