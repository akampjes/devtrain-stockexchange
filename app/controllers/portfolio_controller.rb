class PortfolioController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = current_user
    @portfolio = GeneratePortfolio.new(user: current_user).call
  end
end
