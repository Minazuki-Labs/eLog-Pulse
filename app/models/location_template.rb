class LocationTemplate < ApplicationRecord
  belongs_to :creator, class_name: "User", foreign_key: :created_by_id

  has_many :location_template_items, dependent: :destroy
  has_many :equipment_categories, through: :location_template_items

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :description, length: { maximum: 500 }
  before_validation :normalize_name

  private

  def normalize_name
    self.name = name.squish if name.present?
  end
end
