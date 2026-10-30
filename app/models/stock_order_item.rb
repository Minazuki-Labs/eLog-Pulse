class StockOrderItem < ApplicationRecord
  belongs_to :stock_order
  belongs_to :stock_sub_item

  validates :quantity, presence: true, numericality: { greater_than: 0 }
end
