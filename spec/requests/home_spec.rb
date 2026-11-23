require "rails_helper"

RSpec.describe "Homes", type: :request do
  describe "GET /index" do
    it "redirects unauthenticated users" do
      get "/home/index"
      expect(response).to have_http_status(:redirect)
    end

    it "returns http success for a signed-in user" do
      user = create(:user)
      sign_in user

      get "/home/index"
      expect(response).to have_http_status(:success)
    end

    it "renders the Support Tickets heading and New Ticket link for non-contractor users" do
      user = create(:user, :school)
      sign_in user

      get "/home/index"

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Support Tickets")
      expect(response.body).to include(new_ticket_path)
    end

    it "hides the New Ticket link and shows the empty state when a contractor has no tickets" do
      contractor = create(:user, :contractor)
      sign_in contractor

      get "/home/index"

      expect(response).to have_http_status(:success)
      expect(response.body).not_to include(new_ticket_path)
      expect(response.body).to include("No incomplete tickets found.")
    end
  end
end
