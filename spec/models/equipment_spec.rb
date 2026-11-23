require "rails_helper"

RSpec.describe Equipment, type: :model do
  # ── Associations ──────────────────────────────────────────────
  describe "associations" do
    it { is_expected.to belong_to(:location) }
    it { is_expected.to belong_to(:equipment_category) }
    it { is_expected.to have_many(:tickets) }
  end

  # ── Validations ───────────────────────────────────────────────
  describe "validations" do
    it "validates uniqueness of equipment_category_id scoped to location_id" do
      category = create(:equipment_category)
      location = create(:location)
      create(:equipment, equipment_category: category, location: location)

      duplicate = build(:equipment, equipment_category: category, location: location)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:equipment_category_id]).to include("is already assigned to this location")
    end

    it "allows the same equipment_category in a different location" do
      school = create(:user, :school)
      location_a = create(:location, school: school)
      location_b = create(:location, school: school)
      category = create(:equipment_category)
      create(:equipment, equipment_category: category, location: location_a)

      other_location_equipment = build(:equipment, equipment_category: category, location: location_b)

      expect(other_location_equipment).to be_valid
    end
  end

  # ── Delegation & Helpers ──────────────────────────────────────
  describe "delegation and display_name" do
    it "delegates equipment_category_name to equipment_category" do
      category = create(:equipment_category, name: "Smartboards")
      equipment = build(:equipment, equipment_category: category)

      expect(equipment.equipment_category_name).to eq("Smartboards")
      expect(equipment.display_name).to eq("Smartboards")
    end
  end
end
