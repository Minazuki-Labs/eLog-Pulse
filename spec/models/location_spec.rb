require "rails_helper"

RSpec.describe Location, type: :model do
  # ── Associations ──────────────────────────────────────────────
  describe "associations" do
    it { is_expected.to belong_to(:school).class_name("User") }
    it { is_expected.to have_many(:equipment).dependent(:destroy) }
    it { is_expected.to have_many(:tickets) }
    it { is_expected.to accept_nested_attributes_for(:equipment).allow_destroy(true) }
  end

  # ── Validations ───────────────────────────────────────────────
  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }

    it "validates uniqueness of name scoped to school_id" do
      school = create(:user, :school)
      create(:location, school: school, name: "Lab 1")

      duplicate = build(:location, school: school, name: "Lab 1")

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:name]).to be_present
    end

    it "allows the same location name for a different school" do
      school_a = create(:user, :school)
      school_b = create(:user, :school)
      create(:location, school: school_a, name: "Lab 1")

      other_school_location = build(:location, school: school_b, name: "Lab 1")

      expect(other_school_location).to be_valid
    end

    describe "#owner_must_be_a_school" do
      it "is valid when school has the school role" do
        location = build(:location, school: build(:user, :school))
        expect(location).to be_valid
      end

      it "is invalid when school does not have the school role" do
        employee = build(:user, :employee)
        location = build(:location, school: employee)

        expect(location).not_to be_valid
        expect(location.errors[:school]).to include("must have the 'school' role")
      end
    end
  end
end
