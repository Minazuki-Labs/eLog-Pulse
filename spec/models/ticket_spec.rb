require 'rails_helper'

RSpec.describe Ticket, type: :model do
  # Suppress mailer callbacks during most tests
  before do
    allow(TicketMailer).to receive_message_chain(:new_ticket, :deliver_later)
    allow(TicketMailer).to receive_message_chain(:new_comment, :deliver_later)
  end

  # ── Associations ──────────────────────────────────────────────
  describe "associations" do
    it { is_expected.to belong_to(:school).class_name("User") }
    it { is_expected.to belong_to(:location) }
    it { is_expected.to belong_to(:equipment) }
    it { is_expected.to belong_to(:issue_type) }
    it { is_expected.to belong_to(:assignee).class_name("User").optional }
    it { is_expected.to have_many(:comments).dependent(:destroy) }
  end

  # ── Enums ─────────────────────────────────────────────────────
  describe "enums" do
    it do
      is_expected.to define_enum_for(:status)
        .with_values(new_case: 0, in_progress: 1, completed: 2)
        .with_default(:new_case)
    end
  end

  # ── Validations ───────────────────────────────────────────────
  describe "validations" do
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:teacher_name) }
    it { is_expected.to validate_presence_of(:teacher_phone_number) }
    it { is_expected.to validate_presence_of(:teacher_email) }
    it { is_expected.to allow_value("teacher@school.edu").for(:teacher_email) }
    it { is_expected.not_to allow_value("not-an-email").for(:teacher_email) }

    describe "equipment_must_belong_to_location" do
      it "is valid when equipment belongs to the ticket's location" do
        ticket = build(:ticket)
        expect(ticket).to be_valid
      end

      it "is invalid when equipment belongs to a different location" do
        school = create(:user, :school)
        location_a = create(:location, school: school)
        location_b = create(:location, school: school)
        category = create(:equipment_category)
        equipment_in_b = create(:equipment, location: location_b, equipment_category: category)
        issue_type = category.issue_types.where.not(name: "Other").first

        ticket = build(:ticket,
          school: school,
          location: location_a,
          equipment: equipment_in_b,
          issue_type: issue_type
        )

        expect(ticket).not_to be_valid
        expect(ticket.errors[:equipment]).to include("must be located in the selected room (#{location_a.name})")
      end
    end

    describe "validate_contractor_permissions" do
      let(:contractor) { create(:user, :contractor) }

      it "prevents a contractor from setting status to completed" do
        ticket = create(:ticket, status: :in_progress)
        ticket.updater = contractor
        ticket.status = :completed

        expect(ticket).not_to be_valid
        expect(ticket.errors[:status]).to include("cannot be set to completed by technicians")
      end

      it "allows a contractor to change status to in_progress" do
        ticket = create(:ticket, status: :new_case)
        ticket.updater = contractor
        ticket.status = :in_progress

        expect(ticket).to be_valid
      end

      it "allows an employee to set status to completed" do
        employee = create(:user, :employee)
        ticket = create(:ticket, status: :in_progress)
        ticket.updater = employee
        ticket.status = :completed

        expect(ticket).to be_valid
      end
    end
  end

  # ── Scopes ────────────────────────────────────────────────────
  describe "scopes" do
    describe ".open" do
      it "returns only new_case tickets" do
        new_ticket  = create(:ticket, status: :new_case)
        in_progress = create(:ticket, status: :in_progress)
        completed   = create(:ticket, status: :completed)

        result = Ticket.open
        expect(result).to include(new_ticket)
        expect(result).not_to include(in_progress, completed)
      end
    end

    describe ".not_completed" do
      it "returns new_case and in_progress tickets" do
        new_ticket  = create(:ticket, status: :new_case)
        in_progress = create(:ticket, status: :in_progress)
        completed   = create(:ticket, status: :completed)

        result = Ticket.not_completed
        expect(result).to include(new_ticket, in_progress)
        expect(result).not_to include(completed)
      end
    end

    describe ".recent" do
      it "orders tickets by created_at descending" do
        old_ticket = create(:ticket)
        new_ticket = nil

        travel 1.day do
          new_ticket = create(:ticket)
        end

        expect(Ticket.recent.first).to eq(new_ticket)
        expect(Ticket.recent.last).to eq(old_ticket)
      end
    end
  end

  # ── Warning Methods ──────────────────────────────────────────
  describe "#new_case_warning?" do
    it "returns true when new_case and created more than 3 business days ago" do
      # 3 business days + weekends = at least 5 calendar days to be safe
      ticket = create(:ticket, status: :new_case)
      ticket.update_column(:created_at, 6.days.ago)

      expect(ticket.new_case_warning?).to be true
    end

    it "returns false when new_case and created recently" do
      ticket = create(:ticket, status: :new_case)
      expect(ticket.new_case_warning?).to be false
    end

    it "returns false when in_progress even if old" do
      ticket = create(:ticket, status: :in_progress)
      ticket.update_column(:created_at, 10.days.ago)

      expect(ticket.new_case_warning?).to be false
    end
  end

  describe "#in_progress_warning?" do
    it "returns true when in_progress and not updated for 14+ business days" do
      ticket = create(:ticket, status: :in_progress)
      # 14 business days ≈ 20 calendar days
      ticket.update_column(:updated_at, 21.days.ago)

      expect(ticket.in_progress_warning?).to be true
    end

    it "returns false when in_progress and recently updated" do
      ticket = create(:ticket, status: :in_progress)
      expect(ticket.in_progress_warning?).to be false
    end

    it "returns false when new_case even if stale" do
      ticket = create(:ticket, status: :new_case)
      ticket.update_column(:updated_at, 30.days.ago)

      expect(ticket.in_progress_warning?).to be false
    end
  end

  describe "#warning?" do
    it "returns true if new_case_warning? is true" do
      ticket = create(:ticket, status: :new_case)
      ticket.update_column(:created_at, 6.days.ago)

      expect(ticket.warning?).to be true
    end

    it "returns true if in_progress_warning? is true" do
      ticket = create(:ticket, status: :in_progress)
      ticket.update_column(:updated_at, 21.days.ago)

      expect(ticket.warning?).to be true
    end

    it "returns false when neither warning applies" do
      ticket = create(:ticket, status: :new_case)
      expect(ticket.warning?).to be false
    end
  end

  # ── Editable by School ───────────────────────────────────────
  describe "#editable_by_school?" do
    it "returns true when completed and updated within 9 days" do
      ticket = create(:ticket, status: :completed)
      expect(ticket.editable_by_school?).to be true
    end

    it "returns false when completed but updated more than 9 days ago" do
      ticket = create(:ticket, status: :completed)
      ticket.update_column(:updated_at, 10.days.ago)

      expect(ticket.editable_by_school?).to be false
    end

    it "returns false when not completed" do
      ticket = create(:ticket, status: :in_progress)
      expect(ticket.editable_by_school?).to be false
    end
  end

  # ── Callbacks ─────────────────────────────────────────────────
  describe "callbacks" do
    describe "#set_resolved_at" do
      it "sets resolved_at when status changes to completed" do
        ticket = create(:ticket, status: :new_case)

        freeze_time do
          ticket.update!(status: :completed)
          expect(ticket.resolved_at).to eq(Time.current)
        end
      end

      it "clears resolved_at when status changes away from completed" do
        ticket = create(:ticket, status: :completed)
        expect(ticket.resolved_at).to be_present

        ticket.update!(status: :in_progress)
        expect(ticket.resolved_at).to be_nil
      end

      it "preserves existing resolved_at when already set" do
        ticket = create(:ticket, status: :completed)
        original_resolved_at = ticket.resolved_at

        travel 1.hour do
          # Re-saving as completed should not overwrite the timestamp
          ticket.teacher_name = "Updated Name"
          ticket.status = :completed
          ticket.save!

          expect(ticket.resolved_at).to eq(original_resolved_at)
        end
      end
    end

    describe "#send_new_ticket_notification" do
      it "enqueues a notification email on create" do
        mailer_double = double("mailer")
        allow(TicketMailer).to receive(:new_ticket).and_return(mailer_double)
        allow(mailer_double).to receive(:deliver_later)

        ticket = create(:ticket)

        expect(TicketMailer).to have_received(:new_ticket).with(ticket)
        expect(mailer_double).to have_received(:deliver_later)
      end
    end

    describe "#log_manual_activity" do
      let(:employee) { create(:user, :employee) }

      it "creates a system_log comment when status changes" do
        ticket = create(:ticket, status: :new_case)
        ticket.updater = employee

        expect {
          ticket.update!(status: :in_progress)
        }.to change { ticket.comments.system_log.count }.by(1)

        log = ticket.comments.system_log.last
        expect(log.tracked_changes["points"].first).to include("Changed status")
      end

      it "creates a system_log comment when assignee changes" do
        assignee = create(:user, :employee)
        ticket = create(:ticket, status: :new_case)
        ticket.updater = employee

        expect {
          ticket.update!(assignee: assignee)
        }.to change { ticket.comments.system_log.count }.by(1)

        log = ticket.comments.system_log.last
        expect(log.tracked_changes["points"].first).to include("Assigned ticket")
      end

      it "does not log when updater is nil" do
        ticket = create(:ticket, status: :new_case)

        expect {
          ticket.update!(status: :in_progress)
        }.not_to change { ticket.comments.system_log.count }
      end

      it "does not log when non-tracked fields change" do
        ticket = create(:ticket)
        ticket.updater = employee

        expect {
          ticket.update!(teacher_name: "New Teacher")
        }.not_to change { ticket.comments.system_log.count }
      end

      it "combines changes into an existing recent log within 5 minutes" do
        ticket = create(:ticket, status: :new_case)
        ticket.updater = employee
        ticket.update!(status: :in_progress)

        assignee = create(:user, :employee)

        expect {
          ticket.updater = employee
          ticket.update!(assignee: assignee)
        }.not_to change { ticket.comments.system_log.count }

        log = ticket.comments.system_log.last
        expect(log.tracked_changes["points"].length).to eq(2)
      end
    end
  end

  # ── CSV Export ────────────────────────────────────────────────
  describe ".to_csv" do
    it "generates valid CSV with headers" do
      ticket = create(:ticket)
      csv_string = Ticket.to_csv(Ticket.where(id: ticket.id))

      csv = CSV.parse(csv_string, headers: true)
      expect(csv.headers).to include("Ticket ID", "School", "Location", "Equipment", "Issue Type")
      expect(csv.length).to eq(1)
    end

    it "includes ticket data in the CSV" do
      ticket = create(:ticket, description: "Projector broken")
      csv_string = Ticket.to_csv(Ticket.where(id: ticket.id))

      csv = CSV.parse(csv_string, headers: true)
      row = csv.first

      expect(row["Ticket ID"]).to eq(ticket.id.to_s)
      expect(row["School"]).to eq(ticket.school.name)
      expect(row["Description"]).to eq("Projector broken")
      expect(row["Assignee"]).to eq("Unassigned")
    end

    it "includes the last user_note comment, not system_log" do
      ticket = create(:ticket)
      user = create(:user)
      create(:comment, ticket: ticket, user: user, body: "First note", jobsheet: "JS-100")
      create(:comment, :system_log, ticket: ticket, user: user)
      create(:comment, ticket: ticket, user: user, body: "Latest note", jobsheet: "JS-200")

      csv_string = Ticket.to_csv(Ticket.where(id: ticket.id))
      csv = CSV.parse(csv_string, headers: true)
      row = csv.first

      expect(row["Last Comment"]).to eq("Latest note")
      expect(row["Jobsheet"]).to eq("JS-200")
      expect(row["Commented By"]).to eq(user.name)
    end

    it "handles tickets with no comments" do
      ticket = create(:ticket)
      csv_string = Ticket.to_csv(Ticket.where(id: ticket.id))

      csv = CSV.parse(csv_string, headers: true)
      row = csv.first

      expect(row["Last Comment"]).to be_nil
      expect(row["Jobsheet"]).to be_nil
    end

    it "shows resolved_at for completed tickets" do
      ticket = create(:ticket, status: :completed)
      csv_string = Ticket.to_csv(Ticket.where(id: ticket.id))

      csv = CSV.parse(csv_string, headers: true)
      row = csv.first

      expect(row["Resolved At"]).to eq(ticket.resolved_at.strftime("%Y-%m-%d"))
    end
  end
end
