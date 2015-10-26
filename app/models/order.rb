class Order < ActiveRecord::Base
  belongs_to :stock
  belongs_to :user

  scope :buy, -> { where(kind: :buy).order(price: :asc, created_at: :asc) }
  scope :sell, -> { where(kind: :sell).order(price: :desc, created_at: :asc) }
  scope :unfulfilled, -> { where(fulfilled_at: nil) }
  # Not really sure that it's appropriate to be ordering on this scope
  scope :fulfilled, -> { where.not(fulfilled_at: nil).order(fulfilled_at: :desc) }
  scope :stock, -> (stock) { where(stock: stock) }

  validates :stock, :user, presence: true
  validates :price, :quantity, numericality: { greater_than: 0 }
  validates :kind, inclusion: { in: %w(buy sell) }
end
