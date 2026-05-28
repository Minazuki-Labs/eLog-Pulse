class Comment < ApplicationRecord
  enum :comment_type, { user_note: 0, system_log: 1 }, default: :user_note

  belongs_to :ticket
  belongs_to :user

  validates :body, presence: true, length: { minimum: 1, maximum: 2000 }, unless: -> { system_log? }
end
