class StockSubItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin!

  def create
    @stock_item = StockItem.find(params[:stock_item_id])
    @stock_sub_item = @stock_item.stock_sub_items.build(stock_sub_item_params)

    if @stock_sub_item.save
      redirect_to edit_stock_item_path(@stock_item), notice: "Sub-item added successfully."
    else
      redirect_to edit_stock_item_path(@stock_item), alert: "Error adding sub-item."
    end
  end

  def destroy
    @stock_sub_item = StockSubItem.find(params[:id])
    stock_item = @stock_sub_item.stock_item
    @stock_sub_item.destroy
    redirect_to edit_stock_item_path(stock_item), notice: "Sub-item deleted."
  end

  private

  def ensure_admin!
    redirect_to root_path, alert: "Unauthorized access." unless current_user.admin?
  end

  def stock_sub_item_params
    params.require(:stock_sub_item).permit(:name, :description)
  end
end
