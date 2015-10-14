class Order < ActiveRecord::Base
  belongs_to :stock
  belongs_to :user

  scope :buy,-> { where(kind: :buy) }
  scope :sell,-> { where(kind: :sell) }

  validates :stock, :user, presence: true
  validates :price, :quantity, numericality: { greater_than: 0 }
  validates :kind, inclusion: { in: %w(buy sell) }
end
