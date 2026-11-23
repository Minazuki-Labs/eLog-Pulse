FactoryBot.define do
  factory :stock_order do
    association :user, factory: [:user, :employee]
    association :school, factory: [:user, :school]
    association :approver_1, factory: [:user, :employee]
    association :company
    teacher_phone_number { "0123456789" }
    teacher_email { "teacher@example.com" }
    status { :pending }

    after(:build) do |order|
      if order.stock_order_items.empty?
        sub_item = create(:stock_sub_item)
        order.stock_order_items << build(:stock_order_item, stock_order: order, stock_sub_item: sub_item)
      end
    end
  end
end
