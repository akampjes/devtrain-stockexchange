class Stock < ActiveRecord::Base
  validates :name, :symbol, presence: true
end
