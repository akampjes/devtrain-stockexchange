class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # define what happens on destroy
  has_many :orders
  has_many :buy_orders
  has_many :sell_orders

  after_initialize :default_values

  def default_values
    self.money ||= 10_000
  end

  def money_available
    buy_orders.unfulfilled.reduce(money) do |sum, order|
      sum - order.max_order_value
    end
  end
end
