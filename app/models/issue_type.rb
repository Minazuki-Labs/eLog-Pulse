class IssueType < ApplicationRecord
  belongs_to :equipment_category

  OTHER_NAME = "Other"

  has_many :tickets

  validates :name, presence: true, uniqueness: { scope: :equipment_category_id }
end
