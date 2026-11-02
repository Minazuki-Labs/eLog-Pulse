class StockOrderItem < ApplicationRecord
  belongs_to :stock_order
  belongs_to :stock_sub_item

  validates :quantity, presence: true, numericality: { greater_than: 0 }

  after_destroy :check_order_items_count

  private

  def check_order_items_count
    if stock_order.stock_order_items.reload.empty?
      stock_order.update_column(:status, StockOrder.statuses[:rejected])
    end
  end
end
