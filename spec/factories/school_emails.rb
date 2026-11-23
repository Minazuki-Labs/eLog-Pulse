FactoryBot.define do
  factory :school_email do
    sequence(:email) { |n| "school#{n}@example.com" }
    association :school, factory: [:user, :school], strategy: :build
  end
end
