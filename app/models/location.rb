class Location < ApplicationRecord
  belongs_to :school, class_name: "User"

  has_many :equipment, dependent: :destroy
  has_many :tickets
end
