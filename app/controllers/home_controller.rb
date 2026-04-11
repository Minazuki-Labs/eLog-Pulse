class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @tickets = Ticket.includes(:school, :location, :issue_type, equipment: :equipment_category).recent

    case params[:scope]
    when "assigned"
      @tickets = @tickets.assigned_to(current_user)
    when "open"
      @tickets = @tickets.open
    end
  end
end
