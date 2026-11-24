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

    it "sorts contractor schools case-insensitively without raising a SQL DISTINCT order error" do
      contractor = create(:user, :contractor)

      school_z = create(:user, :school, name: "zebra high school", state: :selangor)
      school_a = create(:user, :school, name: "Alpha Academy", state: :selangor)
      other_school = create(:user, :school, name: "Ignored School", state: :selangor)

      create(:ticket, school: school_z, assignee: contractor, status: :in_progress)
      create(:ticket, school: school_a, assignee: contractor, status: :in_progress)
      create(:ticket, school: other_school, status: :in_progress)

      sign_in contractor

      get "/home/index"

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Alpha Academy")
      expect(response.body).to include("zebra high school")
      expect(response.body).not_to include("Ignored School")
      expect(response.body.index("Alpha Academy")).to be < response.body.index("zebra high school")
    end
  end
end
