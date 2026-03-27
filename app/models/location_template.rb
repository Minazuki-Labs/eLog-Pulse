class LocationTemplate < ApplicationRecord
  belongs_to :creator, class_name: "User", foreign_key: :created_by_id

  has_many :template_items, dependent: :destroy
  has_many :equipment_categories, through: :template_items
end
