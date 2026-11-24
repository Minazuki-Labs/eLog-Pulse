FactoryBot.define do
  factory :issue_type do
    sequence(:name) { |n| "Issue #{n}" }
    association :equipment_category
  end
end
