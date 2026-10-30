class StockItem < ApplicationRecord
  has_many :stock_sub_items, dependent: :destroy

  validates :name, presence: true
end
