require "rails_helper"

RSpec.describe StockOrder, type: :model do
  let(:requester) { create(:user, :employee) }
  let(:school) { create(:user, :school) }
  let(:approver1) { create(:user, :employee) }
  let(:approver2) { create(:user, :employee) }
  let(:contractor) { create(:user, :contractor) }
  let(:stock_item) { StockItem.create!(name: "Parts") }
  let(:sub_item) { StockSubItem.create!(stock_item: stock_item, name: "Part 1") }

  def build_valid_order(attrs = {})
    attrs = attrs.dup
    skip_item = attrs.delete(:skip_item)

    order = described_class.new({
      user: requester,
      school: school,
      approver_1: approver1,
      teacher_phone_number: "0123456789",
      teacher_email: "teacher@example.com"
    }.merge(attrs))

    order.stock_order_items.build(stock_sub_item: sub_item, quantity: 1) if order.stock_order_items.empty? && !skip_item
    order
  end

  before do
    allow(StockOrderMailer).to receive_message_chain(:order_created, :deliver_later)
    allow(StockOrderMailer).to receive_message_chain(:approval_required, :deliver_later)
    allow(StockOrderMailer).to receive_message_chain(:order_in_delivery, :deliver_later)
    allow(StockOrderMailer).to receive_message_chain(:order_completed, :deliver_later)
  end

  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:school).class_name("User") }
    it { is_expected.to belong_to(:contractor).class_name("User").optional }
    it { is_expected.to belong_to(:company).optional }
    it { is_expected.to belong_to(:approver_1).class_name("User").optional }
    it { is_expected.to belong_to(:approver_2).class_name("User").optional }
    it { is_expected.to have_many(:stock_order_items).dependent(:destroy) }
    it { is_expected.to have_many(:stock_sub_items).through(:stock_order_items) }
    it { is_expected.to have_one_attached(:order_proof) }
    it { is_expected.to accept_nested_attributes_for(:stock_order_items).allow_destroy(true) }
  end

  describe "enums" do
    it do
      is_expected.to define_enum_for(:status)
        .with_values(pending: 0, rejected: 1, in_delivery: 2, completed: 3)
    end
  end

  describe "validations" do
    it "is valid with required attributes and at least one item" do
      expect(build_valid_order).to be_valid
    end

    it "requires stock_order_items" do
      order = build_valid_order(skip_item: true)
      expect(order).not_to be_valid
      expect(order.errors[:stock_order_items]).to be_present
    end

    it "requires company_id unless pending with blank approver_2_id and contractor_id" do
      order = build_valid_order(status: :in_delivery, company_id: nil)
      order.order_proof.attach(
        Rack::Test::UploadedFile.new(StringIO.new("proof"), "application/pdf", original_filename: "proof.pdf")
      )

      expect(order).not_to be_valid
      expect(order.errors[:company_id]).to be_present
    end

    it "requires order_proof when status is in_delivery or completed" do
      order = build_valid_order(status: :in_delivery)
      expect(order).not_to be_valid
      expect(order.errors[:order_proof]).to be_present

      order.status = :completed
      expect(order).not_to be_valid
      expect(order.errors[:order_proof]).to be_present
    end

    it "prevents approver_2 from matching user or approver_1" do
      same_as_user = build_valid_order(approver_2: requester)
      expect(same_as_user).not_to be_valid
      expect(same_as_user.errors[:approver_2_id]).to be_present

      same_as_approver1 = build_valid_order(approver_2: approver1)
      expect(same_as_approver1).not_to be_valid
      expect(same_as_approver1.errors[:approver_2_id]).to be_present
    end

    it "prevents contractor from matching approver_2" do
      order = build_valid_order(approver_2: approver2, contractor: approver2)
      expect(order).not_to be_valid
      expect(order.errors[:contractor_id]).to be_present
    end
  end

  describe "callbacks" do
    it "auto-sets status to in_delivery when order_proof is attached while pending" do
      order = build_valid_order(status: :pending)
      order.order_proof.attach(
        Rack::Test::UploadedFile.new(StringIO.new("proof"), "application/pdf", original_filename: "proof.pdf")
      )
      order.save!

      expect(order.reload.status).to eq("in_delivery")
    end

    it "enqueues creation and first approval emails on create" do
      order = build_valid_order
      order.save!

      expect(StockOrderMailer).to have_received(:order_created).with(order)
      expect(StockOrderMailer).to have_received(:approval_required).with(order, approver1)
    end

    it "enqueues approval email when approver_2 is assigned" do
      company = Company.create!(name: "Vendor Corp")
      order = build_valid_order(company: company)
      order.save!
      order.update!(approver_2: approver2)

      expect(StockOrderMailer).to have_received(:approval_required).with(order, approver2)
    end
  end

  describe "#active_id" do
    it "returns contractor_id first, then approver_2_id, then approver_1_id" do
      order = build_valid_order(approver_1: approver1, approver_2: approver2, contractor: contractor)
      expect(order.active_id).to eq(contractor.id)

      order.contractor = nil
      expect(order.active_id).to eq(approver2.id)

      order.approver_2 = nil
      expect(order.active_id).to eq(approver1.id)
    end
  end

  describe "#can_modify_items?" do
    it "allows admins to modify items" do
      admin = create(:user, :employee, admin: true)
      order = build_valid_order

      expect(order.can_modify_items?(admin)).to be true
    end

    it "denies non-admins once a contractor is assigned" do
      order = build_valid_order(contractor: contractor)
      expect(order.can_modify_items?(approver1)).to be false
    end

    it "checks approver_2 if present, otherwise approver_1" do
      order = build_valid_order(approver_1: approver1, approver_2: approver2)
      expect(order.can_modify_items?(approver2)).to be true
      expect(order.can_modify_items?(approver1)).to be false

      order.approver_2 = nil
      expect(order.can_modify_items?(approver1)).to be true
    end
  end

  describe ".accessible_by" do
    it "returns all orders for non-contractor, non-manager admins" do
      admin = create(:user, :employee, admin: true, manager: false)
      order = build_valid_order
      order.save!

      expect(described_class.accessible_by(admin)).to include(order)
    end

    it "returns own orders for standard users" do
      other_user = create(:user, :employee)
      own_order = build_valid_order(user: requester).tap(&:save!)
      other_order = build_valid_order(user: other_user, approver_1: other_user).tap(&:save!)

      result = described_class.accessible_by(requester)
      expect(result).to include(own_order)
      expect(result).not_to include(other_order)
    end
  end
end
