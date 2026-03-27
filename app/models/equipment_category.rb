class EquipmentCategory < ApplicationRecord
  has_many :equipment, dependent: :destroy
  has_many :issue_types, dependent: :destroy
  has_many :location_template_items

  validates :name, presence: true
end
