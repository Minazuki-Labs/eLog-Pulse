FactoryBot.define do
  factory :comment do
    body { "This is a comment" }
    jobsheet { "JS-001" }
    comment_type { :user_note }
    association :ticket
    association :user

    trait :system_log do
      comment_type { :system_log }
      body { "Ticket updated" }
      jobsheet { nil }
    end
  end
end
