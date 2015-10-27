require 'rails_helper'

RSpec.describe Position, kind: :concept do
  describe '#position_percentage_delta' do
    it 'calculates a percentage increase' do
      position = Position.new(stock: nil,
                              quantity: 100,
                              market_price: 2,
                              cost: 100
                             )

      expect(position.percentage_change).to eq 100.0
    end

    it 'calculates a percentage decrease' do
      position = Position.new(stock: nil,
                              quantity: 100,
                              market_price: 1,
                              cost: 200
                             )

      expect(position.percentage_change).to eq -50.0
    end
  end
end
