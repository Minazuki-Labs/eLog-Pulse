require "rails_helper"

RSpec.describe "Settings", type: :request do
  let(:school) { create(:user, :school) }

  before do
    sign_in school
  end

  describe "PATCH /setting" do
    it "adds a new school email" do
      expect {
        patch setting_path, params: {
          user: {
            school_emails_attributes: {
              "0" => { id: school.school_emails.first.id, email: school.school_emails.first.email },
              "1" => { email: "second@school.edu.my" }
            }
          }
        }
      }.to change { school.school_emails.reload.count }.by(1)

      expect(school.school_emails.pluck(:email)).to include("second@school.edu.my")
      expect(response).to redirect_to(edit_setting_path)
    end

    it "removes an existing school email when _destroy is set and at least one remains" do
      extra_email = create(:school_email, school: school, email: "remove-me@school.edu.my")
      keep_email = school.school_emails.first

      expect {
        patch setting_path, params: {
          user: {
            school_emails_attributes: {
              "0" => { id: keep_email.id, email: keep_email.email, _destroy: "false" },
              "1" => { id: extra_email.id, email: extra_email.email, _destroy: "1" }
            }
          }
        }
      }.to change { school.school_emails.reload.count }.by(-1)

      expect(SchoolEmail.exists?(extra_email.id)).to be false
      expect(response).to redirect_to(edit_setting_path)
    end
  end
end
