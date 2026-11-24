FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "User #{n}" }
    sequence(:username) { |n| "user#{n}" }
    password { "password123" }
    role { :employee }

    trait :employee do
      role { :employee }
    end

    trait :school do
      role { :school }
      state { :selangor }
      email { nil }
      after(:build) do |user|
        user.school_emails << build(:school_email, school: user) if user.school_emails.empty?
      end
    end

    trait :contractor do
      role { :contractor }
    end

    trait :admin do
      admin { true }
    end

    trait :manager do
      manager { true }
    end

    trait :teacher do
      teacher { true }
    end
  end
end
