FactoryBot.define do
  factory :app_config do
    sequence(:key) { |n| "config_key_#{n}" }
    value { "some_value" }
  end
end
