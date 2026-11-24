FactoryBot.define do
  factory :stock_sub_item do
    sequence(:name) { |n| "Sub Item #{n}" }
    description { "A sub item" }
    association :stock_item
  end
end
