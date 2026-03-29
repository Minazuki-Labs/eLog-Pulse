class Comment < ApplicationRecord
  belongs_to :ticket
  belongs_to :user

  validates :body, presence: true, length: { minimum: 1, maximum: 2000 }
end
