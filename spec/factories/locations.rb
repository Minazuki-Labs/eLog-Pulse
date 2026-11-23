FactoryBot.define do
  factory :location do
    sequence(:name) { |n| "Room #{n}" }
    association :school, factory: [:user, :school]
  end
end
