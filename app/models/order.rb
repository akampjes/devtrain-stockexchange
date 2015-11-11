class Order < ActiveRecord::Base
  belongs_to :stock
  belongs_to :user

  scope :unfulfilled, -> { where(fulfilled_at: nil) }
  scope :fulfilled, -> { where.not(fulfilled_at: nil) }
  scope :active, -> { where(status: nil).where(fulfilled_at: nil) }
  scope :by_recently_fulfilled, -> { order(fulfilled_at: :desc) }
  scope :by_recently_created, -> { order(created_at: :desc) }
  scope :stock, -> (stock) { where(stock: stock) }
  scope :for_user, -> (user) { where(user: user) }

  validates :stock, :user, presence: true
  validates :price, :quantity, numericality: { greater_than: 0 }
  validates :type, inclusion: { in: %w(BuyOrder SellOrder) }

  def cancel!
    update(status: 'canceled') unless fulfilled?
  end

  def canceled?
    status == 'canceled'
  end

  def active?
    !canceled? && !fulfilled?
  end

  def fulfilled?
    fulfilled_at.present?
  end

  def quantity_filled
    fills.sum(:quantity)
  end

  def quantity_unfilled
    quantity - quantity_filled
  end
end
