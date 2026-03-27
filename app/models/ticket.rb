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
  validates :description, presence: true
  validates :status, :priority, presence: true

  validates :custom_issue_text, presence: true, if: :needs_custom_text?
  validate :equipment_must_belong_to_location

  scope :open, -> { where(status: [ :pending, :in_progress ]) }
  scope :high_priority, -> { where(priority: :high) }

  private

  def needs_custom_text?
    issue_type&.other?
  end

  def equipment_must_belong_to_location
    return unless equipment && location

    if equipment.location_id != location_id
      errors.add(:equipment, "must be located in the selected room (#{location.name})")
    end
  end
end
