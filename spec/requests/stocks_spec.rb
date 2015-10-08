require 'rails_helper'

RSpec.describe "Stocks", type: :request do
  describe "GET /stocks" do
    it "works! (now write some real specs)" do
      get stocks_path
      expect(response).to have_http_status(200)
    end
  end
end
