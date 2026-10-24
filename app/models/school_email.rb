class SchoolEmail < ApplicationRecord
  belongs_to :school, class_name: "User", foreign_key: :school_id, optional: true

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: { scope: :school_id }
end
