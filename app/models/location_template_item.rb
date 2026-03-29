class LocationTemplateItem < ApplicationRecord
  belongs_to :location_template
  belongs_to :equipment_category

  validates :equipment_category_id, uniqueness: { scope: :location_template_id }
end
