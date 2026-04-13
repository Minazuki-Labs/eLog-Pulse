class TicketsController < ApplicationController
  def show
    @ticket = Ticket.includes(:school, :equipment, :issue_type, :location, :comments).find(params[:id])
  end
end
