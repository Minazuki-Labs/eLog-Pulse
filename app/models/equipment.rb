class Equipment < ApplicationRecord
  belongs_to :location
  belongs_to :equipment_category

  has_many :tickets

  validates :equipment_category_id, uniqueness: { scope: :location_id, message: "is already assigned to this location" }

  delegate :name, to: :equipment_category, prefix: true

  def display_name
    "#{equipment_category_name}"
  end
end
