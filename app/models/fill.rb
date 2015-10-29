class Fill < ActiveRecord::Base
  belongs_to :buy_order
  belongs_to :sell_order

  validates :buy_order, :sell_order, presence: true
  validates :price, :quantity, numericality: { greater_than: 0 }
  validates :kind, inclusion: { in: %w(buy sell) }
end
