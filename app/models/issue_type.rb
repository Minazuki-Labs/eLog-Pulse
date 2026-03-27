class IssueType < ApplicationRecord
  OTHER_NAME = "Other".freeze

  belongs_to :equipment_category

  has_many :tickets

  validates :name, presence: true, uniqueness: { scope: :equipment_category_id }

  scope :other, -> { where(name: OTHER_NAME) }

  def other?
    name == OTHER_NAME
  end
end
