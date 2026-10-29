class User < ApplicationRecord
  devise :database_authenticatable, :rememberable, authentication_keys: [ :username ]

  enum :role, { admin: 0, employee: 1, school: 2, contractor: 3 }, validate: true
  enum :state, {
    johor: 0, kedah: 1, kelantan: 2, melaka: 3,
    negeri_sembilan: 4, pahang: 5, penang: 6, perak: 7,
    perlis: 8, sabah: 9, sarawak: 10, selangor: 11,
    terengganu: 12, kuala_lumpur: 13, labuan: 14, putrajaya: 15
  }

  has_many :school_emails, foreign_key: :school_id, dependent: :destroy
  accepts_nested_attributes_for :school_emails

  has_many :employee_schools, foreign_key: :school_id, dependent: :destroy
  has_many :assigned_employees, through: :employee_schools, source: :employee

  has_many :employer_schools, class_name: "EmployeeSchool", foreign_key: :employee_id, dependent: :destroy
  has_many :assigned_schools, through: :employer_schools, source: :school
  has_many :assigned_tickets, class_name: "Ticket", foreign_key: :assignee_id, dependent: :nullify

  has_many :locations, foreign_key: :school_id
  has_many :reported_tickets, class_name: "Ticket", foreign_key: :school_id
  has_many :location_templates, foreign_key: :created_by_id

  has_many :comments

  validates :password, presence: true, length: { minimum: 6 }, on: :create
  validates :password, length: { minimum: 6 }, allow_blank: true, on: :update
  validates :name, presence: true
  validates :username, presence: true, uniqueness: true
  validates :state, presence: true, if: :school?
  validates :school_emails, length: { in: 1..3 }, if: :school?

  scope :staff, -> { where(role: [ :admin, :employee ]) }
  scope :directory_users, -> { where(role: [ :admin, :employee, :contractor ]) }

  def staff?
    admin? || employee?
  end

  def initials
    display_name = (name.presence || username).to_s.strip
    parts = display_name.split

    if parts.length >= 2
      (parts[0][0] + parts[1][0]).upcase
    else
      display_name[0..1].upcase
    end
  end
end
