class Fill < ActiveRecord::Base
  belongs_to :buy_order, class_name: 'Order'
  belongs_to :sell_order, class_name: 'Order'

  validates :buy_order, :sell_order, presence: true
  validates :price, :quantity, numericality: { greater_than: 0 }
  validates :kind, inclusion: { in: %w(buy sell) }
end
