require 'rails_helper'

require 'models/order_spec'

RSpec.describe BuyOrder, type: :model do
  include_examples 'an order', 'buy_order'
end
