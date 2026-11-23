require 'rails_helper'

RSpec.describe User, type: :model do
  # ── Associations ──────────────────────────────────────────────
  describe "associations" do
    # School-side associations
    it { is_expected.to have_many(:school_emails).with_foreign_key(:school_id).dependent(:destroy) }
    it { is_expected.to have_many(:employee_schools).with_foreign_key(:school_id).dependent(:destroy) }
    it { is_expected.to have_many(:assigned_employees).through(:employee_schools).source(:employee) }
    it { is_expected.to have_many(:locations).with_foreign_key(:school_id) }
    it { is_expected.to have_many(:reported_tickets).class_name("Ticket").with_foreign_key(:school_id) }

    # Employee-side associations
    it { is_expected.to have_many(:employer_schools).class_name("EmployeeSchool").with_foreign_key(:employee_id).dependent(:destroy) }
    it { is_expected.to have_many(:assigned_schools).through(:employer_schools).source(:school) }
    it { is_expected.to have_many(:assigned_tickets).class_name("Ticket").with_foreign_key(:assignee_id).dependent(:nullify) }

    # General associations
    it { is_expected.to have_many(:comments) }
    it { is_expected.to have_many(:stock_orders).dependent(:destroy) }
    it { is_expected.to have_many(:contracted_stock_orders).class_name("StockOrder").with_foreign_key(:contractor_id).dependent(:nullify) }
    it { is_expected.to have_many(:approved_stock_orders_as_first).class_name("StockOrder").with_foreign_key(:approver_1_id).dependent(:nullify) }
    it { is_expected.to have_many(:approved_stock_orders_as_second).class_name("StockOrder").with_foreign_key(:approver_2_id).dependent(:nullify) }
    it { is_expected.to have_many(:school_stock_orders).class_name("StockOrder").with_foreign_key(:school_id).dependent(:destroy) }

    it { is_expected.to accept_nested_attributes_for(:school_emails) }
  end

  # ── Enums ─────────────────────────────────────────────────────
  describe "enums" do
    it { is_expected.to define_enum_for(:role).with_values(employee: 1, school: 2, contractor: 3) }

    it do
      is_expected.to define_enum_for(:state).with_values(
        johor: 0, kedah: 1, kelantan: 2, melaka: 3,
        negeri_sembilan: 4, pahang: 5, penang: 6, perak: 7,
        perlis: 8, sabah: 9, sarawak: 10, selangor: 11,
        terengganu: 12, kuala_lumpur: 13, labuan: 14, putrajaya: 15
      )
    end
  end

  # ── Validations ───────────────────────────────────────────────
  describe "validations" do
    subject { build(:user) }

    # Always-on validations
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:username) }
    it { is_expected.to validate_uniqueness_of(:username) }
    it { is_expected.to allow_value("user@example.com").for(:email) }
    it { is_expected.not_to allow_value("not-an-email").for(:email) }
    it { is_expected.to allow_value("").for(:email) }
    it { is_expected.to allow_value(nil).for(:email) }

    # Password on create
    context "on create" do
      subject { build(:user) }

      it "is invalid without a password" do
        subject.password = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:password]).to be_present
      end

      it "is invalid with a password shorter than 6 characters" do
        subject.password = "12345"
        expect(subject).not_to be_valid
        expect(subject.errors[:password]).to be_present
      end

      it "is valid with a password of 6+ characters" do
        subject.password = "123456"
        expect(subject).to be_valid
      end
    end

    # Password on update
    context "on update" do
      subject { create(:user) }

      it "allows updating without changing the password" do
        subject.name = "New Name"
        expect(subject).to be_valid
      end

      it "rejects a password shorter than 6 characters when changing it" do
        subject.password = "12345"
        expect(subject).not_to be_valid
        expect(subject.errors[:password]).to be_present
      end

      it "accepts a password of 6+ characters when changing it" do
        subject.password = "newpassword"
        expect(subject).to be_valid
      end
    end

    # School-specific validations
    context "when role is school" do
      subject { build(:user, :school) }

      it { is_expected.to be_valid }

      it "requires state" do
        subject.state = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:state]).to be_present
      end

      it "requires at least 1 school_email" do
        subject.school_emails = []
        expect(subject).not_to be_valid
      end

      it "allows up to 3 school_emails" do
        subject.school_emails = build_list(:school_email, 3, school: subject)
        expect(subject).to be_valid
      end

      it "rejects more than 3 school_emails" do
        subject.school_emails = build_list(:school_email, 4, school: subject)
        expect(subject).not_to be_valid
      end

      it "rejects a direct email on a school user" do
        subject.email = "direct@example.com"
        expect(subject).not_to be_valid
        expect(subject.errors[:email]).to include("cannot be assigned directly to a school user")
      end
    end

    # Non-school users
    context "when role is employee" do
      subject { build(:user, :employee) }

      it "does not require state" do
        subject.state = nil
        expect(subject).to be_valid
      end

      it "does not require school_emails" do
        subject.school_emails = []
        expect(subject).to be_valid
      end

      it "allows a direct email" do
        subject.email = "employee@example.com"
        expect(subject).to be_valid
      end
    end

    context "when role is contractor" do
      subject { build(:user, :contractor) }

      it "does not require state" do
        subject.state = nil
        expect(subject).to be_valid
      end

      it "allows a direct email" do
        subject.email = "contractor@example.com"
        expect(subject).to be_valid
      end
    end
  end

  # ── Scopes ────────────────────────────────────────────────────
  describe ".staff" do
    it "returns employees and contractors, but not school users" do
      employee   = create(:user, :employee)
      contractor = create(:user, :contractor)
      school     = create(:user, :school)

      result = User.staff

      expect(result).to include(employee, contractor)
      expect(result).not_to include(school)
    end
  end

  # ── Instance Methods ──────────────────────────────────────────
  describe "#staff?" do
    it "returns true for an employee" do
      expect(build(:user, :employee).staff?).to be true
    end

    it "returns true for a contractor" do
      expect(build(:user, :contractor).staff?).to be true
    end

    it "returns false for a school" do
      expect(build(:user, :school).staff?).to be false
    end
  end

  describe "#initials" do
    it "returns the first letter of the first two words" do
      user = build(:user, name: "Ahmad Bin Ali")
      expect(user.initials).to eq("AB")
    end

    it "takes the first two letters of a single-word name" do
      user = build(:user, name: "Ahmad")
      expect(user.initials).to eq("AH")
    end

    it "uppercases the initials" do
      user = build(:user, name: "john doe")
      expect(user.initials).to eq("JD")
    end

    it "falls back to username when name is blank" do
      user = build(:user, name: nil, username: "admin")
      # name is required so we skip validation for this unit test
      user.define_singleton_method(:name) { nil }
      expect(user.initials).to eq("AD")
    end

    it "handles names with more than two parts" do
      user = build(:user, name: "Siti Nur Aisyah")
      expect(user.initials).to eq("SN")
    end
  end

  # ── Boolean Flags ─────────────────────────────────────────────
  describe "admin/manager/teacher flags" do
    it "defaults admin to false" do
      expect(build(:user).admin).to be false
    end

    it "defaults manager to false" do
      expect(build(:user).manager).to be false
    end

    it "defaults teacher to false" do
      expect(build(:user).teacher).to be false
    end

    it "can be set to true" do
      user = build(:user, admin: true, manager: true, teacher: true)
      expect(user.admin).to be true
      expect(user.manager).to be true
      expect(user.teacher).to be true
    end
  end
end
