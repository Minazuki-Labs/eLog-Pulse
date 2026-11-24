require "rails_helper"

RSpec.describe StockItem, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:stock_sub_items).dependent(:destroy) }
    it { is_expected.to accept_nested_attributes_for(:stock_sub_items).allow_destroy(true) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe "dependent destroy" do
    it "destroys associated stock_sub_items when destroyed" do
      item = described_class.create!(name: "Projector Lamps")
      sub_item = StockSubItem.create!(stock_item: item, name: "Lamp A")

      expect { item.destroy! }.to change { StockSubItem.exists?(sub_item.id) }.from(true).to(false)
    end
  end
end
