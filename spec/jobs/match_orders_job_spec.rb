require 'rails_helper'

RSpec.describe MatchOrdersJob, type: :job do
  let(:stock) { create(:stock) }

  describe '#perform' do
    it 'Calls Matchorders' do
      match_orders_instance = instance_double('FulfillOrder')
      allow(MatchOrders).to receive(:new).with(stock: stock).and_return(match_orders_instance)
      expect(match_orders_instance).to receive(:call)

      MatchOrdersJob.perform_now(stock: stock)
    end
  end
end
