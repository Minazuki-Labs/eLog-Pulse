require "rails_helper"

RSpec.describe IssueType, type: :model do
  # ── Associations ──────────────────────────────────────────────
  describe "associations" do
    it { is_expected.to belong_to(:equipment_category) }
    it { is_expected.to have_many(:tickets) }
  end

  # ── Validations ───────────────────────────────────────────────
  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }

    it "validates uniqueness of name scoped to equipment_category_id" do
      category = create(:equipment_category)
      existing = category.issue_types.first

      duplicate = build(:issue_type, equipment_category: category, name: existing.name)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:name]).to be_present
    end

    it "allows the same issue type name under a different equipment_category" do
      category_a = create(:equipment_category)
      category_b = create(:equipment_category)
      create(:issue_type, equipment_category: category_a, name: "Power Issue")

      same_name_in_b = build(:issue_type, equipment_category: category_b, name: "Power Issue")

      expect(same_name_in_b).to be_valid
    end
  end
end
