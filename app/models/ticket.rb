class Ticket < ApplicationRecord
  enum :status, { new_case: 0, in_progress: 1, completed: 2 }, default: :new_case

  belongs_to :school, class_name: "User"
  belongs_to :location
  belongs_to :equipment
  belongs_to :issue_type

  has_many :comments, dependent: :destroy

  attr_accessor :updater

  validates :status, :teacher_name, :teacher_phone_number, :teacher_email, presence: true
  validates :teacher_email, format: { with: URI::MailTo::EMAIL_REGEXP }

  validate :equipment_must_belong_to_location

  after_update :log_manual_activity, if: -> { updater.present? && tracking_changes_present? }

  scope :open, -> { where(status: [ :new_case ]) }
  scope :recent, -> { order(created_at: :desc) }
  scope :not_completed, -> { where.not(status: :completed) }

  private

  def equipment_must_belong_to_location
    if equipment && location && equipment.location_id != location_id
      errors.add(:equipment, "must be located in the selected room (#{location.name})")
    end
  end

  def tracking_changes_present?
    (saved_changes.keys & %w[status]).any?
  end

  def log_manual_activity
    new_changes = []

    # Status changes
    if saved_changes.key?("status")
      old_val, new_val = saved_changes["status"]
      new_changes << "Changed status from <b>#{old_val.to_s.titleize}</b> to <b>#{new_val.to_s.titleize}</b>"
    end

    return if new_changes.empty?

    # Look for an existing system log by this user on this ticket in the last 5 minutes
    recent_log = comments.system_log
                         .where(user: updater)
                         .where("created_at >= ?", 5.minutes.ago)
                         .order(created_at: :desc)
                         .first

    if recent_log
      existing_changes = recent_log.tracked_changes.is_a?(Hash) ? (recent_log.tracked_changes["points"] || []) : []
      combined_changes = existing_changes + new_changes

      recent_log.update!(
        tracked_changes: { "points" => combined_changes },
        updated_at: Time.current
      )
    else
      comments.create!(
        user: updater,
        comment_type: :system_log,
        body: "Ticket updated",
        tracked_changes: { "points" => new_changes }
      )
    end
  end
end
