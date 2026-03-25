class TemplateItem < ApplicationRecord
  belongs_to :location_template
  belongs_to :equipment_category
end
