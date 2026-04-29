class Ticket < ApplicationRecord
  enum :status, { pending: 0, in_progress: 1, completed: 2 }, default: :pending
  enum :priority, { low: 0, medium: 1, high: 2 }, default: :low

  belongs_to :school, class_name: "User"
  belongs_to :employee, class_name: "User", optional: true
  belongs_to :location
  belongs_to :equipment
  belongs_to :issue_type

  has_many :comments, dependent: :destroy

  validates :school_id, :location_id, :equipment_id, :issue_type_id, presence: true
  validates :status, :priority, presence: true

  validate :equipment_must_belong_to_location

  scope :open, -> { where(status: [ :pending ]) }
  scope :high_priority, -> { where(priority: :high) }

  scope :assigned_to, ->(user) { where(employee: user) }
  scope :recent, -> { order(created_at: :desc) }
  scope :unassigned, -> { where(employee_id: nil) }
  scope :not_completed, -> { where.not(status: :completed) }

  private

  def equipment_must_belong_to_location
    if equipment && location && equipment.location_id != location_id
      errors.add(:equipment, "must be located in the selected room (#{location.name})")
    end
  end
end
