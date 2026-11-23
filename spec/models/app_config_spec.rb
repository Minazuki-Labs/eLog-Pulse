require "rails_helper"

RSpec.describe AppConfig, type: :model do
  # ── Validations ───────────────────────────────────────────────
  describe "validations" do
    subject { build(:app_config) }

    it { is_expected.to validate_presence_of(:key) }
    it { is_expected.to validate_uniqueness_of(:key) }
  end

  # ── Class Methods ─────────────────────────────────────────────
  describe "class methods" do
    describe ".group_email" do
      it "returns nil when the group_email record does not exist" do
        expect(described_class.group_email).to be_nil
      end

      it "returns the value when the group_email record exists" do
        create(:app_config, key: "group_email", value: "support@example.com")

        expect(described_class.group_email).to eq("support@example.com")
      end
    end

    describe ".group_email=" do
      it "creates a new group_email record when none exists" do
        expect {
          described_class.group_email = "team@example.com"
        }.to change(described_class, :count).by(1)

        record = described_class.find_by(key: "group_email")
        expect(record).to be_present
        expect(record.value).to eq("team@example.com")
      end

      it "updates the existing group_email record without creating a duplicate" do
        existing = create(:app_config, key: "group_email", value: "old@example.com")

        expect {
          described_class.group_email = "new@example.com"
        }.not_to change(described_class, :count)

        expect(existing.reload.value).to eq("new@example.com")
      end
    end
  end
end
