class Ticket < ApplicationRecord
  belongs_to :school
  belongs_to :employee
  belongs_to :location
  belongs_to :equipment
  belongs_to :issue_type
end
