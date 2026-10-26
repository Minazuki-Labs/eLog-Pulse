class EmployeeSchool < ApplicationRecord
  belongs_to :employee, class_name: "User"
  belongs_to :school, class_name: "User"
end
