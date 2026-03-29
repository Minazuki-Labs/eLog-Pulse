class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  enum :role, { admin: 0, employee: 1, school: 2 }, validate: true

  has_many :locations, foreign_key: :school_id
  has_many :reported_tickets, class_name: "Ticket", foreign_key: :school_id

  has_many :assigned_tickets, class_name: "Ticket", foreign_key: :employee_id
  has_many :location_templates, foreign_key: :created_by_id

  has_many :comments

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  scope :staff, -> { where(role: [ :admin, :employee ]) }
end
