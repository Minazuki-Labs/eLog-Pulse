class Ticket < ApplicationRecord
  enum :status, { new_case: 0, in_progress: 1, completed: 2 }, default: :new_case

  belongs_to :school, class_name: "User"
  belongs_to :location
  belongs_to :equipment
  belongs_to :issue_type
  belongs_to :assignee, class_name: "User", optional: true

  has_many :comments, dependent: :destroy

  attr_accessor :updater

  validates :status, :teacher_name, :teacher_phone_number, :teacher_email, presence: true
  validates :teacher_email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validate :equipment_must_belong_to_location
  validate :validate_contractor_permissions, if: -> { updater&.contractor? }

  after_update :log_manual_activity, if: -> { updater.present? && tracking_changes_present? }

  scope :open, -> { where(status: [ :new_case ]) }
  scope :recent, -> { order(created_at: :desc) }
  scope :not_completed, -> { where.not(status: :completed) }

  after_create :send_new_ticket_notification

  def new_case_warning?
    new_case? && created_at <= business_days_ago(3)
  end

  def in_progress_warning?
    in_progress? && updated_at <= business_days_ago(14)
  end

  def warning?
    new_case_warning? || in_progress_warning?
  end

  def editable_by_school?
    completed? && updated_at >= 9.days.ago
  end

  def self.to_csv(tickets)
    headers = [ "School", "Location", "Equipment", "Issue Type", "Description", "Created At", "Resolved At", "Assignee", "Last Comment", "Commented By", "Commented At" ]

    CSV.generate(headers: true) do |csv|
      csv << headers

      tickets.includes(:school, :location, :issue_type, :assignee, equipment: :equipment_category, comments: :user).each do |ticket|
        last_comment = ticket.comments
                             .select(&:user_note?)
                             .max_by(&:created_at)

        csv << [
          ticket.school&.name,
          ticket.location&.name,
          ticket.equipment&.display_name || "Equipment ##{ticket.equipment_id}",
          ticket.issue_type&.name,
          ticket.description,
          ticket.created_at&.strftime("%Y-%m-%d %H:%M"),
          ticket.resolved_at&.strftime("%Y-%m-%d %H:%M"),
          ticket.assignee&.name || "Unassigned",
          last_comment&.body,
          last_comment&.user&.name,
          last_comment&.created_at&.strftime("%Y-%m-%d %H:%M")
        ]
      end
    end
  end

  private

  def business_days_ago(business_days)
    current_date = Time.current
    added_days = 0

    while added_days < business_days
      current_date -= 1.day
      added_days += 1 unless current_date.on_weekend?
    end

    current_date
  end

  def equipment_must_belong_to_location
    if equipment && location && equipment.location_id != location_id
      errors.add(:equipment, "must be located in the selected room (#{location.name})")
    end
  end

  def validate_contractor_permissions
    if completed? && status_changed?
      errors.add(:status, "cannot be set to completed by technicians")
    end
  end

  def tracking_changes_present?
    (saved_changes.keys & %w[status assignee_id]).any?
  end

  def log_manual_activity
    new_changes = []

    # Status changes
    if saved_changes.key?("status")
      old_val, new_val = saved_changes["status"]
      new_changes << "Changed status from <b>#{old_val.to_s.titleize}</b> to <b>#{new_val.to_s.titleize}</b>"
    end

    # Assignee changes
    if saved_changes.key?("assignee_id")
      old_assignee = User.find_by(id: saved_changes["assignee_id"][0])
      new_assignee = User.find_by(id: saved_changes["assignee_id"][1])

      old_name = old_assignee ? old_assignee.name : "Unassigned"
      new_name = new_assignee ? new_assignee.name : "Unassigned"
      new_changes << "Assigned ticket from <b>#{old_name}</b> to <b>#{new_name}</b>"
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

  def send_new_ticket_notification
    TicketMailer.new_ticket(self).deliver_later
  end
end
