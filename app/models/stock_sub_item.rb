class StockSubItem < ApplicationRecord
  belongs_to :stock_item
  has_many :stock_order_items, dependent: :restrict_with_error
  has_many :stock_orders, through: :stock_order_items

  validates :name, presence: true
end
