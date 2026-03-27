class EquipmentCategory < ApplicationRecord
  belongs_to :school, class_name: "User"

  has_many :equipment, dependent: :destroy
  has_many :issue_types, foreign_key: :equipment_category_id, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :school_id }
end
