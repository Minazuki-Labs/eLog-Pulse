class TicketsController < ApplicationController
  def show
    @ticket = Ticket.includes(:school, :equipment, :issue_type, :location, :comments).find(params[:id])
  end

  def update
    @ticket = Ticket.find(params[:id])
    if @ticket.update(ticket_params)
      redirect_to @ticket, notice: "Status updated to #{@ticket.status.humanize}"
    else
      redirect_to @ticket, alert: "Update failed."
    end
  end

  private

  def ticket_params
    params.require(:ticket).permit(:status, :priority, :description, :location_id)
  end
end
