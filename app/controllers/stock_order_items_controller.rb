class StockOrderItemsController < ApplicationController
  before_action :authenticate_user!

  def destroy
    @stock_order = StockOrder.accessible_by(current_user).find(params[:stock_order_id])
    @stock_order_item = @stock_order.stock_order_items.find(params[:id])

    if current_user.admin? || current_user.manager?
      @stock_order_item.destroy
      redirect_to @stock_order, notice: "Item removed from order."
    else
      redirect_to @stock_order, alert: "Unauthorized action."
    end
  end
end
