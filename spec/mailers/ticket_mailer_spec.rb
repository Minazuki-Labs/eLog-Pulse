require "rails_helper"

RSpec.describe TicketMailer, type: :mailer do
  describe "new_comment" do
    let(:school) do
      create(
        :user,
        role: :school,
        state: :selangor,
        email: nil,
        school_emails_attributes: [ { email: "school@example.com" } ]
      )
    end
    let(:author) { create(:user, role: :employee) }
    let(:location) { create(:location, school: school) }
    let(:equipment) { create(:equipment, location: location) }
    let(:issue_type) { create(:issue_type) }
    let(:ticket) do
      create(
        :ticket,
        school: school,
        location: location,
        equipment: equipment,
        issue_type: issue_type,
        teacher_name: "Jane Doe",
        teacher_phone_number: "0123456789",
        teacher_email: "teacher@example.com",
        status: :new_case
      )
    end
    let(:comment) do
      create(
        :comment,
        ticket: ticket,
        user: author,
        body: "Hi there",
        jobsheet: "JS-001",
        comment_type: :user_note
      )
    end
    let(:mail) { TicketMailer.new_comment(comment) }

    before do
      allow(AppConfig).to receive(:group_email).and_return("group@example.com")
    end

    it "renders the headers" do
      expect(mail.subject).to eq("Update on Ticket ##{ticket.id} - Status: New case")
      expect(mail.to).to include("group@example.com", "school@example.com", "teacher@example.com")
      expect(mail.from).to eq([ "elog@multiple.com.my" ])
    end

    it "renders the body" do
      expect(mail.body.encoded).to include("Hi there")
    end
  end
end
