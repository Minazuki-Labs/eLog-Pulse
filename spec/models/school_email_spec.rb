require "rails_helper"

RSpec.describe SchoolEmail, type: :model do
  # ── Associations ──────────────────────────────────────────────
  describe "associations" do
    it { is_expected.to belong_to(:school).class_name("User") }
  end

  # ── Validations ───────────────────────────────────────────────
  describe "validations" do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to allow_value("admin@school.edu.my").for(:email) }
    it { is_expected.not_to allow_value("invalid-email").for(:email) }

    it "validates uniqueness of email scoped to school_id" do
      school = create(:user, :school)
      create(:school_email, school: school, email: "office@school.edu.my")

      duplicate = build(:school_email, school: school, email: "office@school.edu.my")

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:email]).to be_present
    end

    it "allows the same email for a different school" do
      school_a = create(:user, :school)
      school_b = create(:user, :school)
      create(:school_email, school: school_a, email: "office@school.edu.my")

      other_school_email = build(:school_email, school: school_b, email: "office@school.edu.my")

      expect(other_school_email).to be_valid
    end
  end
end
