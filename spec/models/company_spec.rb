require "rails_helper"

RSpec.describe Company, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:stock_orders).dependent(:nullify) }
  end

  describe "validations" do
    subject { build(:company) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
  end

  describe "dependent nullify" do
    it "nullifies company_id on associated stock_orders when destroyed" do
      company = described_class.create!(name: "Acme Supplies")
      requester = create(:user, :employee)
      school = create(:user, :school)
      approver1 = create(:user, :employee)
      stock_item = StockItem.create!(name: "Supplies")
      sub_item = StockSubItem.create!(stock_item: stock_item, name: "Item A")

      order = StockOrder.new(
        user: requester,
        school: school,
        approver_1: approver1,
        company: company,
        teacher_phone_number: "0123456789",
        teacher_email: "teacher@example.com"
      )
      order.stock_order_items.build(stock_sub_item: sub_item, quantity: 1)
      order.save!

      company.destroy!

      expect(order.reload.company_id).to be_nil
    end
  end
end
