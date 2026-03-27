class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, { admin: 0, employee: 1, school: 2 }

  has_many :locations, foreign_key: :school_id
  has_many :equipment_categories, foreign_key: :school_id
  has_many :reported_tickets, class_name: "Ticket", foreign_key: :school_id

  has_many :assigned_tickets, class_name: "Ticket", foreign_key: :employee_id
  has_many :location_templates, foreign_key: :created_by_id

  has_many :comments
end
