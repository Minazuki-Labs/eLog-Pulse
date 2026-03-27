class Ticket < ApplicationRecord
  enum :status, { pending: 0, in_progress: 1, completed: 2 }, default: :pending
  enum :priority, { low: 0, medium: 1, high: 2 }, default: :low

  belongs_to :school, class_name: "User"
  belongs_to :employee, class_name: "User", optional: true
  belongs_to :location
  belongs_to :equipment
  belongs_to :issue_type

  has_many :comments, dependent: :destroy
end
