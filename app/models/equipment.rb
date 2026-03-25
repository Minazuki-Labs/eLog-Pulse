class Equipment < ApplicationRecord
  belongs_to :location
  belongs_to :equipment_category
end
