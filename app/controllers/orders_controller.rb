class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :destroy]

  # GET /orders
  # GET /orders.json
  def index
    @orders = Order.for_user(current_user).by_recently_created
  end

  # GET /orders/new
  def new
    @order = Order.new
  end

  # POST /orders
  # POST /orders.json
  def create
    @order = CreateOrder.new(order: current_user.orders.new(order_params)).call

    respond_to do |format|
      if @order.errors.empty?

        format.html { redirect_to orders_path, notice: 'Order was successfully created.' }
        format.json { render :show, status: :created, location: @order }
      else
        format.html { render :new }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
    @order.destroy
    respond_to do |format|
      format.html { redirect_to orders_url, notice: 'Order was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_order
    @order = Order.for_user(current_user).find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def order_params
    params.require(:order).permit(:stock_id, :type, :quantity, :price)
  end
end
