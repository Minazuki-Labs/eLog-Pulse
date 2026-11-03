class Company < ApplicationRecord
  has_many :stock_orders, dependent: :nullify

  validates :name, presence: true, uniqueness: true
end
