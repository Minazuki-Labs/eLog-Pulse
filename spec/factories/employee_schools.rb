FactoryBot.define do
  factory :employee_school do
    association :employee, factory: [ :user, :employee ]
    association :school, factory: [ :user, :school ]
  end
end
