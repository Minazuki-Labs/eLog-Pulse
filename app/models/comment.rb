class Comment < ApplicationRecord
  enum :comment_type, { user_note: 0, system_log: 1 }, default: :user_note

  belongs_to :ticket
  belongs_to :user

  validates :body, presence: true, length: { minimum: 1, maximum: 2000 }, unless: -> { system_log? }
  validates :jobsheet, presence: true, unless: -> { system_log? }

  after_create_commit :send_comment_email, unless: -> { system_log? }

  private

  def send_comment_email
    TicketMailer.new_comment(self).deliver_later
  end
end
