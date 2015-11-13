class StocksController < ApplicationController
  before_action :authenticate_user!, except: [:index]

  def index
    @stocks = Stock.all
  end

  def show
    @stock = Stock.find(params[:id])
  end

  private
    def stock_params
      params.require(:stock).permit(:name, :symbol)
    end
end
