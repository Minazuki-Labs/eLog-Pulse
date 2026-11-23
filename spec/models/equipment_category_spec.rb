require "rails_helper"

RSpec.describe EquipmentCategory, type: :model do
  # ── Associations ──────────────────────────────────────────────
  describe "associations" do
    it { is_expected.to have_many(:equipment).dependent(:destroy) }
    it { is_expected.to have_many(:issue_types).dependent(:destroy) }
    it { is_expected.to accept_nested_attributes_for(:issue_types).allow_destroy(true) }
  end

  # ── Validations & Callbacks ───────────────────────────────────
  describe "validations and callbacks" do
    it { is_expected.to validate_presence_of(:name) }

    it "auto-creates the 'Other' issue type when at least one custom issue is provided" do
      category = described_class.new(
        name: "Projectors",
        issue_types_attributes: [ { name: "No Display" } ]
      )

      expect(category).to be_valid
      category.save!

      names = category.issue_types.pluck(:name)
      expect(names).to include("No Display", IssueType::OTHER_NAME)
    end

    it "requires at least one non-'Other' issue type" do
      category = described_class.new(name: "Projectors")

      expect(category).not_to be_valid
      expect(category.errors[:base]).to include("At least one equipment issue must be provided.")
    end

    it "prevents manually entering more than one 'Other' issue type" do
      category = described_class.new(
        name: "Projectors",
        issue_types_attributes: [
          { name: "Lamp Dim" },
          { name: IssueType::OTHER_NAME },
          { name: "other" }
        ]
      )

      expect(category).not_to be_valid
      expect(category.errors[:base]).to include(
        "The 'Other' issue is added automatically and cannot be entered manually."
      )
    end

    it "destroys dependent equipment and issue_types when destroyed" do
      category = create(:equipment_category)
      location = create(:location)
      equipment = create(:equipment, equipment_category: category, location: location)
      issue_types_count = category.issue_types.count

      expect { category.destroy! }
        .to change { described_class.count }.by(-1)
        .and change { Equipment.exists?(equipment.id) }.from(true).to(false)
        .and change { IssueType.count }.by(-issue_types_count)
    end
  end
end
