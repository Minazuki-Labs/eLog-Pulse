class IssueType < ApplicationRecord
  belongs_to :equipment_category

  has_many :tickets
end
