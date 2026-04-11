class TicketsController < ApplicationController
  def show
    @ticket = Ticket.includes(:equipment, :issue_type, :location, :comments).find(params[:id])
  end
end
