require "rails_helper"

RSpec.describe StockOrderItem, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:stock_order) }
    it { is_expected.to belong_to(:stock_sub_item) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:quantity) }
    it { is_expected.to validate_numericality_of(:quantity).is_greater_than(0) }
  end

  describe "callbacks" do
    describe "#check_order_items_count" do
      it "marks the stock_order as rejected when the last item is destroyed" do
        requester = create(:user, :employee)
        school = create(:user, :school)
        approver1 = create(:user, :employee)
        stock_item = StockItem.create!(name: "Toners")
        sub_item = StockSubItem.create!(stock_item: stock_item, name: "Black Toner")

        order = StockOrder.new(
          user: requester,
          school: school,
          approver_1: approver1,
          teacher_phone_number: "0123456789",
          teacher_email: "teacher@example.com",
          status: :pending
        )
        item = order.stock_order_items.build(stock_sub_item: sub_item, quantity: 1)
        order.save!

        item.destroy!

        expect(order.reload.status).to eq("rejected")
      end

      it "does not reject the stock_order when other items remain" do
        requester = create(:user, :employee)
        school = create(:user, :school)
        approver1 = create(:user, :employee)
        stock_item = StockItem.create!(name: "Toners")
        sub_item_1 = StockSubItem.create!(stock_item: stock_item, name: "Black Toner")
        sub_item_2 = StockSubItem.create!(stock_item: stock_item, name: "Cyan Toner")

        order = StockOrder.new(
          user: requester,
          school: school,
          approver_1: approver1,
          teacher_phone_number: "0123456789",
          teacher_email: "teacher@example.com",
          status: :pending
        )
        item_1 = order.stock_order_items.build(stock_sub_item: sub_item_1, quantity: 1)
        order.stock_order_items.build(stock_sub_item: sub_item_2, quantity: 1)
        order.save!

        item_1.destroy!

        expect(order.reload.status).to eq("pending")
      end
    end
  end
end
