class StockItem < ApplicationRecord
  has_many :stock_sub_items, dependent: :destroy

  accepts_nested_attributes_for :stock_sub_items, allow_destroy: true

  validates :name, presence: true
end
