class StockItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin!, except: [ :index, :show ]
  before_action :set_stock_item, only: [ :show, :edit, :update, :destroy ]

  def index
    @stock_items = StockItem.includes(:stock_sub_items).all
    if params[:query].present?
      @stock_items = @stock_items.where("name LIKE ? OR description LIKE ?", "%#{params[:query]}%", "%#{params[:query]}%")
    end
  end

  def show
  end

  def new
    @stock_item = StockItem.new
    @stock_item.stock_sub_items.build
  end

  def create
    @stock_item = StockItem.new(stock_item_params)
    if @stock_item.save
      redirect_to stock_items_path, notice: "Stock item was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @stock_item.stock_sub_items.build if @stock_item.stock_sub_items.empty?
  end

  def update
    if @stock_item.update(stock_item_params)
      redirect_to stock_items_path, notice: "Stock item was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @stock_item.destroy
    redirect_to stock_items_path, notice: "Stock item was successfully deleted."
  end

  private

  def ensure_admin!
    redirect_to root_path, alert: "Unauthorized access." unless current_user.admin?
  end

  def set_stock_item
    @stock_item = StockItem.find(params[:id])
  end

  def stock_item_params
    params.require(:stock_item).permit(:name, :description, stock_sub_items_attributes: [ :id, :name, :description, :_destroy ])
  end
end
