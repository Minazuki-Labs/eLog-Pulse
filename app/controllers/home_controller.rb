class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @tickets = if current_user.school?
      current_user.reported_tickets
    elsif current_user.employee?
      Ticket.where(school_id: current_user.assigned_schools.select(:id))
    else
      Ticket.all
    end
  end
end
