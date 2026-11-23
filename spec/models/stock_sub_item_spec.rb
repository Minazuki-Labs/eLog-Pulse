require "rails_helper"

RSpec.describe StockSubItem, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:stock_item) }
    it { is_expected.to have_many(:stock_order_items).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:stock_orders).through(:stock_order_items) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe "dependent restriction" do
    it "prevents destruction when referenced by a stock_order_item" do
      category = create(:equipment_category)
      school = create(:user, :school)
      location = create(:location, school: school)
      equipment = create(:equipment, location: location, equipment_category: category)
      issue_type = category.issue_types.first
      _ticket = create(:ticket, school: school, location: location, equipment: equipment, issue_type: issue_type)

      requester = create(:user, :employee)
      approver1 = create(:user, :employee)
      stock_item = StockItem.create!(name: "Cables")
      sub_item = StockSubItem.create!(stock_item: stock_item, name: "HDMI Cable")

      order = StockOrder.new(
        user: requester,
        school: school,
        approver_1: approver1,
        teacher_phone_number: "0123456789",
        teacher_email: "teacher@example.com"
      )
      order.stock_order_items.build(stock_sub_item: sub_item, quantity: 2)
      order.save!

      expect(sub_item.destroy).to be false
      expect(sub_item.errors[:base]).to be_present
    end
  end
end
