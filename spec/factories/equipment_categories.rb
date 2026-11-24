FactoryBot.define do
  factory :equipment_category do
    sequence(:name) { |n| "Category #{n}" }

    after(:build) do |category|
      if category.issue_types.empty?
        category.issue_types << build(:issue_type, name: "Default Issue", equipment_category: category)
      end
    end
  end
end
