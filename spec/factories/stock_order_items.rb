FactoryBot.define do
  factory :stock_order_item do
    association :stock_order
    association :stock_sub_item
    quantity { 1 }
  end
end
