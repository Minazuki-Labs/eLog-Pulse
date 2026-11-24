FactoryBot.define do
  factory :stock_item do
    sequence(:name) { |n| "Stock Item #{n}" }
    description { "A stock item" }
  end
end
