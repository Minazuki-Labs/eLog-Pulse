FactoryBot.define do
  factory :equipment do
    association :location
    association :equipment_category
  end
end
