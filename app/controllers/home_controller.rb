class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    if current_user.school?
      @tickets = current_user.reported_tickets.order(created_at: :desc)
    else
      @tickets = Ticket.all.order(created_at: :desc)
    end
  end
end
