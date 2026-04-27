class User < ApplicationRecord
  devise :database_authenticatable, :recoverable, :rememberable, :validatable

  enum :role, { admin: 0, employee: 1, school: 2 }, validate: true

  has_many :locations, foreign_key: :school_id
  has_many :reported_tickets, class_name: "Ticket", foreign_key: :school_id

  has_many :assigned_tickets, class_name: "Ticket", foreign_key: :employee_id
  has_many :location_templates, foreign_key: :created_by_id

  has_many :comments

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  scope :staff, -> { where(role: [ :admin, :employee ]) }

  def staff?
    admin? || employee?
  end

  def initials
    display_name = (name.presence || email).to_s.strip
    parts = display_name.split

    if parts.length >= 2
      (parts[0][0] + parts[1][0]).upcase
    else
      display_name[0..1].upcase
    end
  end
end
