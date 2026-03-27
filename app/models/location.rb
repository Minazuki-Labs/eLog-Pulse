class Location < ApplicationRecord
  belongs_to :school, class_name: "User"

  has_many :equipment, dependent: :destroy
  has_many :tickets

  validates :name, presence: true, uniqueness: { scope: :school_id }
end
