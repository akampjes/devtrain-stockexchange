class Stock < ActiveRecord::Base
  has_many :orders

  validates :name, :symbol, presence: true
end
