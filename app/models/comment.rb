class Comment < ApplicationRecord
  enum :comment_type, { user_note: 0, system_log: 1 }, default: :user_note

  belongs_to :ticket
  belongs_to :user

  has_one_attached :attachment

  validates :body, presence: true, length: { minimum: 1, maximum: 2000 }, unless: -> { system_log? }
  validates :jobsheet, presence: true, unless: -> { system_log? || user&.school? }
  validate :acceptable_attachment, if: -> { attachment.attached? }

  after_create_commit :send_comment_email, unless: -> { system_log? }

  private

  def acceptable_attachment
    return unless attachment.attached?

    unless attachment.content_type.in?(%w[image/png image/jpeg application/pdf])
      errors.add(:attachment, "must be a JPEG, PNG, or PDF")
    end
  end

  def send_comment_email
    TicketMailer.new_comment(self).deliver_later
  end
end
