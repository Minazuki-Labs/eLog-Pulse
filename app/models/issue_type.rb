class IssueType < ApplicationRecord
  belongs_to :equipment_category

  has_many :tickets

  validates :name, presence: true, uniqueness: { scope: :equipment_category_id }
end
