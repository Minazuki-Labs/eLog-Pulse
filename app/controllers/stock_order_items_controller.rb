class StockOrderItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_stock_order_and_item, only: [ :update, :destroy ]

  def update
    if current_user.admin? || current_user.manager? || @stock_order.can_modify_items?(current_user)
      if @stock_order_item.update(stock_order_item_params)
        respond_to do |format|
          format.html { redirect_to @stock_order, notice: "Item quantity updated." }
          format.turbo_stream
        end
      else
        respond_to do |format|
          format.html { redirect_to @stock_order, alert: @stock_order_item.errors.full_messages.to_sentence }
          format.turbo_stream { render turbo_stream: turbo_stream.replace(@stock_order_item, partial: "stock_order_items/item_row", locals: { stock_order: @stock_order, item: @stock_order_item, can_modify: true }) }
        end
      end
    else
      redirect_to @stock_order, alert: "Unauthorized action."
    end
  end

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

  private

  def set_stock_order_and_item
    @stock_order = StockOrder.accessible_by(current_user).find(params[:stock_order_id])
    @stock_order_item = @stock_order.stock_order_items.find(params[:id])
  end

  def stock_order_item_params
    params.require(:stock_order_item).permit(:quantity)
  end
end
