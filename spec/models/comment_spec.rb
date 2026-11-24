require "rails_helper"

RSpec.describe Comment, type: :model do
  before do
    allow(TicketMailer).to receive_message_chain(:new_comment, :deliver_later)
  end

  # ── Associations ──────────────────────────────────────────────
  describe "associations" do
    it { is_expected.to belong_to(:ticket) }
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_one_attached(:attachment) }
  end

  # ── Enums ─────────────────────────────────────────────────────
  describe "enums" do
    it "defines comment_type enum with user_note and system_log" do
      is_expected.to define_enum_for(:comment_type)
        .with_values(user_note: 0, system_log: 1)
        .with_default(:user_note)
    end
  end

  # ── Validations ───────────────────────────────────────────────
  describe "validations" do
    describe "body validation" do
      it "requires body when user_note" do
        comment = build(:comment, comment_type: :user_note, body: nil)

        expect(comment).not_to be_valid
        expect(comment.errors[:body]).to be_present
      end

      it "rejects body longer than 2000 characters when user_note" do
        comment = build(:comment, comment_type: :user_note, body: "a" * 2001)

        expect(comment).not_to be_valid
        expect(comment.errors[:body]).to be_present
      end

      it "accepts body up to 2000 characters when user_note" do
        comment = build(:comment, comment_type: :user_note, body: "a" * 2000)

        expect(comment).to be_valid
      end

      it "allows blank body when system_log" do
        comment = build(:comment, :system_log, body: nil)

        expect(comment).to be_valid
      end
    end

    describe "jobsheet validation" do
      it "requires jobsheet for non-school users on user_note comments" do
        user = build(:user, :employee)
        comment = build(:comment, comment_type: :user_note, user: user, jobsheet: nil)

        expect(comment).not_to be_valid
        expect(comment.errors[:jobsheet]).to be_present
      end

      it "allows blank jobsheet for school users on user_note comments" do
        school_user = build(:user, :school)
        comment = build(:comment, comment_type: :user_note, user: school_user, jobsheet: nil)

        expect(comment).to be_valid
      end

      it "allows blank jobsheet when system_log" do
        comment = build(:comment, :system_log, jobsheet: nil)

        expect(comment).to be_valid
      end
    end

    describe "acceptable_attachment" do
      %w[image/png image/jpeg application/pdf].each do |content_type|
        it "accepts #{content_type} attachments" do
          comment = build(:comment)
          file = Rack::Test::UploadedFile.new(
            StringIO.new("valid content"),
            content_type,
            original_filename: "file.bin"
          )
          comment.attachment.attach(file)

          expect(comment).to be_valid
        end
      end

      it "rejects unsupported attachment content types" do
        comment = build(:comment)
        invalid_file = Rack::Test::UploadedFile.new(
          StringIO.new("not allowed"),
          "text/plain",
          original_filename: "notes.txt"
        )
        comment.attachment.attach(invalid_file)

        expect(comment).not_to be_valid
        expect(comment.errors[:attachment]).to include("must be a JPEG, PNG, or PDF")
      end

      it "is valid when no attachment is attached" do
        comment = build(:comment)

        expect(comment.attachment).not_to be_attached
        expect(comment).to be_valid
      end
    end
  end

  # ── Callbacks ─────────────────────────────────────────────────
  describe "callbacks" do
    describe "#send_comment_email" do
      it "enqueues a new_comment email after create for user_note comments" do
        mailer_double = double("mailer")
        allow(TicketMailer).to receive(:new_comment).and_return(mailer_double)
        allow(mailer_double).to receive(:deliver_later)

        comment = create(:comment, comment_type: :user_note)

        expect(TicketMailer).to have_received(:new_comment).with(comment)
        expect(mailer_double).to have_received(:deliver_later)
      end

      it "does not enqueue an email for system_log comments" do
        expect(TicketMailer).not_to receive(:new_comment)

        create(:comment, :system_log)
      end

      it "does not enqueue an email when validation fails" do
        expect(TicketMailer).not_to receive(:new_comment)

        create(:comment, body: nil)
      rescue ActiveRecord::RecordInvalid
        # expected
      end
    end
  end
end
