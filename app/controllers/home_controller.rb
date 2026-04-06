class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @tickets = Ticket.includes(:location, :issue_type, :employee).recent

    case params[:scope]
    when "assigned"
      @tickets = @tickets.assigned_to(current_user)
    when "open"
      @tickets = @tickets.open
    end
  end
end
