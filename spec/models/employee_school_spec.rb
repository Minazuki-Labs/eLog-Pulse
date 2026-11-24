require "rails_helper"

RSpec.describe EmployeeSchool, type: :model do
  # ── Associations ──────────────────────────────────────────────
  describe "associations" do
    it { is_expected.to belong_to(:employee).class_name("User") }
    it { is_expected.to belong_to(:school).class_name("User") }
  end

  # ── Persistence ───────────────────────────────────────────────
  describe "persistence" do
    it "persists a valid employee-school association" do
      employee = create(:user, :employee)
      school = create(:user, :school)

      record = described_class.create!(employee: employee, school: school)

      expect(record).to be_persisted
      expect(record.employee).to eq(employee)
      expect(record.school).to eq(school)
    end
  end
end
